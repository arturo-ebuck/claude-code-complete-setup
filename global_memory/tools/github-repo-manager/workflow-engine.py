#!/usr/bin/env python3
"""
GitHub Repository Management Workflow Engine
Manages automated workflows for claude-code-wsl-setup repository
CRITICAL: Always uses branches, NEVER commits to main
"""

import os
import sys
import yaml
import subprocess
import datetime
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple

class GitHubRepoManager:
    """Automated GitHub repository management with branch-based workflow"""
    
    def __init__(self, config_path: str = "agent-config.yaml"):
        self.config = self._load_config(config_path)
        self.repo_path = None
        self.current_branch = None
        self._setup_logging()
        self._validate_configuration()
        
    def _load_config(self, config_path: str) -> Dict:
        """Load agent configuration from YAML file"""
        config_file = Path(__file__).parent / config_path
        with open(config_file, 'r') as f:
            return yaml.safe_load(f)
            
    def _setup_logging(self):
        """Configure logging for the agent"""
        log_config = self.config['logging']
        logging.basicConfig(
            level=getattr(logging, log_config['level'].upper()),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_config['file']),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger('GitHubRepoManager')
        
    def _validate_configuration(self):
        """Validate critical configuration settings"""
        # Ensure main branch protection is enabled
        if not self.config['safeguards']['prevent_main_commit']:
            raise ValueError("CRITICAL: Main branch protection must be enabled!")
            
        self.logger.info("Configuration validated successfully")
        
    def _run_git_command(self, command: List[str], check: bool = True) -> Tuple[int, str, str]:
        """Execute git command and return result"""
        try:
            result = subprocess.run(
                ['git'] + command,
                cwd=self.repo_path,
                capture_output=True,
                text=True,
                check=check
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Git command failed: {' '.join(command)}")
            return e.returncode, e.stdout, e.stderr
            
    def initialize_repository(self, repo_path: str):
        """Initialize or clone the repository"""
        self.repo_path = Path(repo_path)
        
        if not self.repo_path.exists():
            self.logger.info(f"Cloning repository to {repo_path}")
            clone_url = self.config['repository']['remote_url']
            subprocess.run(['git', 'clone', clone_url, repo_path], check=True)
        else:
            self.logger.info(f"Using existing repository at {repo_path}")
            
        # Ensure we're not on main branch
        self._ensure_not_on_main()
        
    def _ensure_not_on_main(self):
        """CRITICAL: Ensure we're never on the main branch"""
        _, current_branch, _ = self._run_git_command(['branch', '--show-current'])
        current_branch = current_branch.strip()
        
        protected_branches = self.config['branch_protection']['protected_branches']
        if current_branch in protected_branches:
            # Switch to a safe working branch
            safe_branch = f"work/{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
            self.logger.warning(f"On protected branch '{current_branch}', switching to '{safe_branch}'")
            self._run_git_command(['checkout', '-b', safe_branch])
            
    def create_feature_branch(self, branch_type: str, description: str) -> str:
        """Create a new feature branch following naming conventions"""
        timestamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
        
        # Get branch pattern from config
        pattern_key = f"{branch_type}_pattern"
        pattern = self.config['workflow_rules']['branch_strategy'].get(
            pattern_key, 
            "feature/{timestamp}-{description}"
        )
        
        # Format branch name
        branch_name = pattern.format(
            timestamp=timestamp,
            description=description.lower().replace(' ', '-')
        )
        
        self.logger.info(f"Creating branch: {branch_name}")
        
        # Ensure we're on latest main
        self._run_git_command(['fetch', 'origin'])
        self._run_git_command(['checkout', '-b', branch_name, 'origin/main'])
        
        self.current_branch = branch_name
        return branch_name
        
    def commit_changes(self, files: List[str], commit_type: str, scope: str, description: str):
        """Commit changes with conventional commit format"""
        # Verify we're not on main
        self._ensure_not_on_main()
        
        # Stage files
        for file in files:
            self._run_git_command(['add', file])
            
        # Format commit message
        commit_format = self.config['workflow_rules']['commit_conventions']['format']
        commit_message = commit_format.format(
            type=commit_type,
            scope=scope,
            description=description
        )
        
        self.logger.info(f"Committing: {commit_message}")
        self._run_git_command(['commit', '-m', commit_message])
        
    def push_branch(self, set_upstream: bool = True):
        """Push current branch to remote"""
        if not self.current_branch:
            raise ValueError("No current branch set")
            
        # CRITICAL: Verify we're not pushing to main
        protected = self.config['branch_protection']['protected_branches']
        if self.current_branch in protected:
            raise ValueError(f"BLOCKED: Cannot push to protected branch '{self.current_branch}'")
            
        push_cmd = ['push']
        if set_upstream:
            push_cmd.extend(['-u', 'origin', self.current_branch])
        else:
            push_cmd.append('origin')
            
        self.logger.info(f"Pushing branch: {self.current_branch}")
        self._run_git_command(push_cmd)
        
    def create_pull_request(self, title: str, body: str, labels: List[str] = None):
        """Create a pull request using GitHub CLI"""
        # Ensure gh CLI is available
        try:
            subprocess.run(['gh', '--version'], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.logger.error("GitHub CLI (gh) not found. Please install it.")
            return None
            
        pr_cmd = [
            'gh', 'pr', 'create',
            '--title', title,
            '--body', body,
            '--base', self.config['repository']['default_branch']
        ]
        
        if labels:
            pr_cmd.extend(['--label', ','.join(labels)])
            
        if self.config['workflow_rules']['pull_request']['draft_by_default']:
            pr_cmd.append('--draft')
            
        self.logger.info(f"Creating pull request: {title}")
        result = subprocess.run(pr_cmd, cwd=self.repo_path, capture_output=True, text=True)
        
        if result.returncode == 0:
            pr_url = result.stdout.strip()
            self.logger.info(f"Pull request created: {pr_url}")
            return pr_url
        else:
            self.logger.error(f"Failed to create PR: {result.stderr}")
            return None
            
    def process_update(self, update_type: str, files: List[str], description: str):
        """Process an update through the complete workflow"""
        self.logger.info(f"Processing {update_type} update: {description}")
        
        # Create appropriate branch
        branch_type_map = {
            'feature': 'feature',
            'documentation': 'docs',
            'bugfix': 'fix',
            'configuration': 'config',
            'maintenance': 'update'
        }
        
        branch_type = branch_type_map.get(update_type, 'feature')
        branch_name = self.create_feature_branch(branch_type, description)
        
        # Determine commit type and scope
        commit_type = branch_type if branch_type != 'docs' else 'docs'
        scope = self._determine_scope(files)
        
        # Commit changes
        self.commit_changes(files, commit_type, scope, description)
        
        # Push branch
        self.push_branch()
        
        # Create pull request
        pr_title = f"{commit_type}({scope}): {description}"
        pr_body = self._generate_pr_body(update_type, files, description)
        labels = [branch_type, 'automated']
        
        pr_url = self.create_pull_request(pr_title, pr_body, labels)
        
        return {
            'branch': branch_name,
            'commit_type': commit_type,
            'pr_url': pr_url,
            'status': 'success' if pr_url else 'failed'
        }
        
    def _determine_scope(self, files: List[str]) -> str:
        """Determine commit scope based on affected files"""
        if any('doc' in f.lower() for f in files):
            return 'docs'
        elif any('config' in f.lower() or '.yaml' in f or '.json' in f for f in files):
            return 'config'
        elif any('script' in f.lower() or '.sh' in f or '.py' in f for f in files):
            return 'scripts'
        else:
            return 'core'
            
    def _generate_pr_body(self, update_type: str, files: List[str], description: str) -> str:
        """Generate pull request body"""
        body = f"""## Summary
{description}

## Type of Change
- Update Type: {update_type}
- Branch: {self.current_branch}

## Files Changed
"""
        for file in files:
            body += f"- {file}\n"
            
        body += """
## Checklist
- [x] Changes follow branch-based workflow
- [x] Commits follow conventional format
- [x] No direct commits to main branch
- [ ] Tests pass (if applicable)
- [ ] Documentation updated (if needed)

---
*This PR was created automatically by the GitHub Repository Manager*
"""
        return body


# Standalone functions for common operations
def setup_agent():
    """Initial setup of the repository management agent"""
    manager = GitHubRepoManager()
    repo_path = "/home/jb_remus/repos/claude-code-wsl-setup"
    manager.initialize_repository(repo_path)
    return manager
    
def handle_file_update(files: List[str], description: str, update_type: str = "feature"):
    """Handle file updates with automatic workflow"""
    manager = setup_agent()
    result = manager.process_update(update_type, files, description)
    return result
    

if __name__ == "__main__":
    # Example usage
    print("GitHub Repository Management Engine initialized")
    print("CRITICAL: This agent NEVER commits to main branch")
    print("All updates go through feature branches and pull requests")