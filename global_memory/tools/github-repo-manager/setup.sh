#!/bin/bash
# Setup script for GitHub Repository Management System

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_PATH="/home/jb_remus/repos/claude-code-wsl-setup"
LOG_DIR="/home/jb_remus/claude_global_memory/logs"

echo "=== GitHub Repository Management System Setup ==="
echo ""

# Create necessary directories
echo "Creating directories..."
mkdir -p "$LOG_DIR"
mkdir -p "$(dirname "$REPO_PATH")"

# Install Python dependencies
echo "Installing Python dependencies..."
if command -v pip3 &> /dev/null; then
    pip3 install -r "$SCRIPT_DIR/requirements.txt"
else
    echo "ERROR: pip3 not found. Please install Python 3 and pip."
    exit 1
fi

# Check for GitHub CLI
echo "Checking for GitHub CLI..."
if ! command -v gh &> /dev/null; then
    echo "WARNING: GitHub CLI (gh) not found."
    echo "Please install it from: https://cli.github.com/"
    echo "The agent will work but won't be able to create pull requests."
else
    echo "GitHub CLI found: $(gh --version | head -1)"
fi

# Make scripts executable
echo "Setting permissions..."
chmod +x "$SCRIPT_DIR/branch-manager.sh"
chmod +x "$SCRIPT_DIR/workflow-engine.py"
chmod +x "$SCRIPT_DIR/autonomous-agent.py"
chmod +x "$SCRIPT_DIR/commit-hooks/install-hooks.sh"
chmod +x "$SCRIPT_DIR/commit-hooks/pre-commit"
chmod +x "$SCRIPT_DIR/commit-hooks/pre-push"

# Initialize repository
echo ""
echo "Repository Setup:"
if [[ -d "$REPO_PATH/.git" ]]; then
    echo "Repository already exists at: $REPO_PATH"
else
    echo "Repository will be cloned on first use to: $REPO_PATH"
fi

# Create systemd service (optional)
echo ""
read -p "Create systemd service for automatic monitoring? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > /tmp/github-repo-manager.service << EOF
[Unit]
Description=GitHub Repository Manager for claude-code-wsl-setup
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/python3 $SCRIPT_DIR/autonomous-agent.py monitor
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    echo "Systemd service created at: /tmp/github-repo-manager.service"
    echo "To install:"
    echo "  sudo cp /tmp/github-repo-manager.service /etc/systemd/system/"
    echo "  sudo systemctl daemon-reload"
    echo "  sudo systemctl enable github-repo-manager"
    echo "  sudo systemctl start github-repo-manager"
fi

# Create quick-start script
cat > "$SCRIPT_DIR/start-agent.sh" << 'EOF'
#!/bin/bash
# Quick start script for the GitHub Repository Manager

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting GitHub Repository Management Agent..."
echo "Press Ctrl+C to stop"
echo ""

python3 "$SCRIPT_DIR/autonomous-agent.py" monitor
EOF

chmod +x "$SCRIPT_DIR/start-agent.sh"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To start the agent:"
echo "  $SCRIPT_DIR/start-agent.sh"
echo ""
echo "For manual updates:"
echo "  python3 $SCRIPT_DIR/autonomous-agent.py update \"description\" file1 file2..."
echo ""
echo "To use branch manager directly:"
echo "  $SCRIPT_DIR/branch-manager.sh help"
echo ""
echo "IMPORTANT: This system enforces branch-based workflows."
echo "          Direct commits to main branch are BLOCKED."