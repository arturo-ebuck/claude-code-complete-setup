#!/usr/bin/env python3
"""
Autonomous GitHub Repository Management Agent
Monitors and manages claude-code-wsl-setup repository automatically
"""

import os
import sys
import time
import json
import hashlib
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from workflow_engine import GitHubRepoManager

class RepositoryMonitor(FileSystemEventHandler):
    """Monitors repository for changes and triggers automated workflows"""
    
    def __init__(self, repo_path: str, manager: GitHubRepoManager):
        self.repo_path = Path(repo_path)
        self.manager = manager
        self.pending_changes: Dict[str, Set[str]] = {
            'feature': set(),
            'docs': set(),
            'config': set(),
            'fix': set()
        }
        self.last_process_time = 0
        self.process_delay = 30  # Wait 30 seconds before processing
        self.file_hashes = {}
        self._load_file_hashes()
        
    def _load_file_hashes(self):
        """Load existing file hashes to detect actual changes"""
        hash_file = Path("/home/jb_remus/claude_global_memory/tools/github-repo-manager/.file_hashes.json")
        if hash_file.exists():
            with open(hash_file, 'r') as f:
                self.file_hashes = json.load(f)
                
    def _save_file_hashes(self):
        """Save file hashes for change detection"""
        hash_file = Path("/home/jb_remus/claude_global_memory/tools/github-repo-manager/.file_hashes.json")
        with open(hash_file, 'w') as f:
            json.dump(self.file_hashes, f, indent=2)
            
    def _get_file_hash(self, filepath: Path) -> str:
        """Calculate file hash for change detection"""
        if not filepath.exists() or not filepath.is_file():
            return ""
        with open(filepath, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
            
    def _categorize_file(self, filepath: Path) -> str:
        """Categorize file to determine update type"""
        rel_path = filepath.relative_to(self.repo_path)
        path_str = str(rel_path).lower()
        
        if any(doc in path_str for doc in ['readme', 'doc', '.md', 'license']):
            return 'docs'
        elif any(cfg in path_str for cfg in ['config', '.yaml', '.yml', '.json', '.ini']):
            return 'config'
        elif any(script in path_str for script in ['.sh', '.py', 'script']):
            return 'feature'
        else:
            return 'feature'
            
    def _should_ignore_file(self, filepath: Path) -> bool:
        """Check if file should be ignored"""
        ignore_patterns = [
            '.git/', '__pycache__/', '.pyc', '.log', '.tmp',
            '.swp', '.DS_Store', 'node_modules/', '.env'
        ]
        path_str = str(filepath)
        return any(pattern in path_str for pattern in ignore_patterns)
        
    def on_modified(self, event):
        """Handle file modification events"""
        if event.is_directory:
            return
            
        filepath = Path(event.src_path)
        
        # Ignore certain files
        if self._should_ignore_file(filepath):
            return
            
        # Check if file actually changed
        new_hash = self._get_file_hash(filepath)
        old_hash = self.file_hashes.get(str(filepath), "")
        
        if new_hash != old_hash:
            self.file_hashes[str(filepath)] = new_hash
            category = self._categorize_file(filepath)
            rel_path = str(filepath.relative_to(self.repo_path))
            self.pending_changes[category].add(rel_path)
            logging.info(f"Change detected: {rel_path} (category: {category})")
            
    def on_created(self, event):
        """Handle file creation events"""
        if not event.is_directory:
            self.on_modified(event)
            
    def process_pending_changes(self):
        """Process accumulated changes"""
        current_time = time.time()
        
        # Check if enough time has passed
        if current_time - self.last_process_time < self.process_delay:
            return
            
        # Process each category of changes
        for category, files in self.pending_changes.items():
            if files:
                self._process_category_changes(category, list(files))
                files.clear()
                
        self.last_process_time = current_time
        self._save_file_hashes()
        
    def _process_category_changes(self, category: str, files: List[str]):
        """Process changes for a specific category"""
        # Generate description
        if len(files) == 1:
            description = f"Update {files[0]}"
        else:
            description = f"Update {len(files)} {category} files"
            
        try:
            # Initialize repository if needed
            if not hasattr(self.manager, 'repo_path') or not self.manager.repo_path:
                self.manager.initialize_repository(str(self.repo_path))
                
            # Process the update
            result = self.manager.process_update(category, files, description)
            
            if result['status'] == 'success':
                logging.info(f"Successfully processed {category} update: {result['pr_url']}")
            else:
                logging.error(f"Failed to process {category} update")
                
        except Exception as e:
            logging.error(f"Error processing {category} changes: {str(e)}")


class AutonomousAgent:
    """Main autonomous agent for repository management"""
    
    def __init__(self):
        self.setup_logging()
        self.manager = GitHubRepoManager()
        self.repo_path = "/home/jb_remus/repos/claude-code-wsl-setup"
        self.monitor = None
        self.observer = None
        
    def setup_logging(self):
        """Configure logging for the autonomous agent"""
        log_dir = Path("/home/jb_remus/claude_global_memory/logs")
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / "autonomous-agent.log"),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger('AutonomousAgent')
        
    def initialize(self):
        """Initialize the agent and repository"""
        self.logger.info("Initializing Autonomous GitHub Repository Manager")
        
        # Ensure repository exists
        repo_path = Path(self.repo_path)
        if not repo_path.exists():
            self.logger.info(f"Repository not found, cloning to {self.repo_path}")
            self.manager.initialize_repository(self.repo_path)
        else:
            self.logger.info(f"Using existing repository at {self.repo_path}")
            self.manager.repo_path = repo_path
            
        # Install git hooks
        self._install_git_hooks()
        
        # Set up file monitoring
        self.monitor = RepositoryMonitor(self.repo_path, self.manager)
        self.observer = Observer()
        self.observer.schedule(self.monitor, self.repo_path, recursive=True)
        
    def _install_git_hooks(self):
        """Install git hooks for the repository"""
        hooks_dir = Path(__file__).parent / "commit-hooks"
        install_script = hooks_dir / "install-hooks.sh"
        
        if install_script.exists():
            import subprocess
            result = subprocess.run(
                ["bash", str(install_script), self.repo_path],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                self.logger.info("Git hooks installed successfully")
            else:
                self.logger.error(f"Failed to install git hooks: {result.stderr}")
                
    def run(self):
        """Run the autonomous agent"""
        self.initialize()
        
        self.logger.info("Starting repository monitoring...")
        self.observer.start()
        
        try:
            while True:
                # Process pending changes
                self.monitor.process_pending_changes()
                
                # Sleep for a short interval
                time.sleep(5)
                
        except KeyboardInterrupt:
            self.logger.info("Shutting down agent...")
            self.observer.stop()
            
        self.observer.join()
        self.logger.info("Agent stopped")
        
    def handle_manual_update(self, files: List[str], description: str, update_type: str = "feature"):
        """Handle manual update requests"""
        self.logger.info(f"Processing manual update: {description}")
        
        try:
            if not hasattr(self.manager, 'repo_path') or not self.manager.repo_path:
                self.manager.initialize_repository(self.repo_path)
                
            result = self.manager.process_update(update_type, files, description)
            
            if result['status'] == 'success':
                self.logger.info(f"Manual update successful: {result['pr_url']}")
                return result
            else:
                self.logger.error("Manual update failed")
                return None
                
        except Exception as e:
            self.logger.error(f"Error in manual update: {str(e)}")
            return None


def main():
    """Main entry point for the autonomous agent"""
    agent = AutonomousAgent()
    
    if len(sys.argv) > 1:
        # Handle command line arguments
        command = sys.argv[1]
        
        if command == "monitor":
            agent.run()
        elif command == "update" and len(sys.argv) >= 4:
            # Manual update: python autonomous-agent.py update "description" file1 file2...
            description = sys.argv[2]
            files = sys.argv[3:]
            agent.handle_manual_update(files, description)
        else:
            print("Usage:")
            print("  python autonomous-agent.py monitor           # Start monitoring")
            print("  python autonomous-agent.py update DESC FILE... # Manual update")
    else:
        # Default: start monitoring
        agent.run()


if __name__ == "__main__":
    main()