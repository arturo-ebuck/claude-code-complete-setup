#!/usr/bin/env bash
set -euo pipefail

# Claude Code Complete Setup Script
# This script sets up a complete Claude Code environment with all configurations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Log function
log() {
    local level=$1
    shift
    local message="$@"
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} ${level}: ${message}"
}

# Error handler
error_handler() {
    local line_no=$1
    log "${RED}ERROR${NC}" "Script failed at line $line_no"
    exit 1
}
trap 'error_handler ${LINENO}' ERR

# Success message
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running in WSL2
check_wsl() {
    if [[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
        log "${RED}ERROR${NC}" "This script must be run in WSL2 Ubuntu"
        exit 1
    fi
    success "Running in WSL2 environment"
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check git
    if ! command -v git &> /dev/null; then
        log "${RED}ERROR${NC}" "Git is not installed. Please install git first."
        exit 1
    fi
    success "Git is installed"
    
    # Check/Install Node.js
    if ! command -v node &> /dev/null; then
        log "INFO" "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    success "Node.js is installed ($(node --version))"
    
    # Check/Install Python
    if ! command -v python3 &> /dev/null; then
        log "INFO" "Installing Python..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
    fi
    success "Python is installed ($(python3 --version))"
    
    # Check/Install UV (Python package manager)
    if ! command -v uv &> /dev/null; then
        log "INFO" "Installing UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    success "UV is installed"
}

# Backup existing configurations
backup_existing() {
    log "INFO" "Backing up existing configurations..."
    
    if [[ -d "$HOME_DIR/.claude" ]]; then
        cp -r "$HOME_DIR/.claude" "$HOME_DIR/.claude.backup.$TIMESTAMP"
        warning "Backed up existing .claude directory"
    fi
    
    if [[ -d "$HOME_DIR/.config/claude-code" ]]; then
        cp -r "$HOME_DIR/.config/claude-code" "$HOME_DIR/.config/claude-code.backup.$TIMESTAMP"
        warning "Backed up existing claude-code config"
    fi
    
    if [[ -d "$HOME_DIR/claude_global_memory" ]]; then
        cp -r "$HOME_DIR/claude_global_memory" "$HOME_DIR/claude_global_memory.backup.$TIMESTAMP"
        warning "Backed up existing global memory"
    fi
}

# Install Claude Code CLI
install_claude_cli() {
    log "INFO" "Installing Claude Code CLI..."
    
    if ! command -v claude &> /dev/null; then
        npm install -g @anthropic/claude-code-cli
    else
        log "INFO" "Claude Code CLI already installed, checking for updates..."
        npm update -g @anthropic/claude-code-cli
    fi
    
    success "Claude Code CLI installed ($(claude --version))"
}

# Copy configurations
copy_configurations() {
    log "INFO" "Copying configurations..."
    
    # Create directories
    mkdir -p "$HOME_DIR/.claude"
    mkdir -p "$HOME_DIR/.config/claude-code"
    mkdir -p "$HOME_DIR/claude_global_memory"
    mkdir -p "$HOME_DIR/claude-code-desktop02-setup"
    
    # Copy SuperClaude framework
    cp -r "$SCRIPT_DIR/config/claude/"* "$HOME_DIR/.claude/"
    success "Copied SuperClaude framework"
    
    # Copy MCP configurations
    cp "$SCRIPT_DIR/config/claude-code/"* "$HOME_DIR/.config/claude-code/"
    success "Copied MCP server configurations"
    
    # Copy global memory
    cp -r "$SCRIPT_DIR/global_memory/"* "$HOME_DIR/claude_global_memory/"
    success "Copied global memory system"
    
    # Copy setup infrastructure
    cp -r "$SCRIPT_DIR/infrastructure/"* "$HOME_DIR/claude-code-desktop02-setup/"
    success "Copied setup infrastructure"
    
    # Set proper permissions
    chmod 600 "$HOME_DIR/.config/claude-code/claude_desktop_config.json"
    chmod 700 "$HOME_DIR/claude_global_memory"
    success "Set secure file permissions"
}

# Setup environment variables
setup_environment() {
    log "INFO" "Setting up environment variables..."
    
    if [[ -f "$SCRIPT_DIR/.env" ]]; then
        # Copy .env to home directory
        cp "$SCRIPT_DIR/.env" "$HOME_DIR/.env.claude"
        
        # Add sourcing to .bashrc if not already present
        if ! grep -q "source ~/.env.claude" "$HOME_DIR/.bashrc"; then
            echo -e "\n# Claude Code environment variables\n[[ -f ~/.env.claude ]] && source ~/.env.claude" >> "$HOME_DIR/.bashrc"
        fi
        
        # Source for current session
        source "$HOME_DIR/.env.claude"
        success "Environment variables configured"
    else
        warning "No .env file found. You'll need to set up API keys manually."
        warning "Copy .env.example to .env and fill in your API keys."
    fi
}

# Install MCP servers
install_mcp_servers() {
    log "INFO" "Installing MCP servers..."
    
    # Create MCP servers directory
    mkdir -p "$HOME_DIR/claude-code-desktop02-setup/mcp-servers"
    cd "$HOME_DIR/claude-code-desktop02-setup/mcp-servers"
    
    # Install npm-based MCP servers
    log "INFO" "Installing npm-based MCP servers..."
    npm init -y > /dev/null 2>&1
    
    # Core MCP servers
    local npm_servers=(
        "@modelcontextprotocol/server-filesystem"
        "@modelcontextprotocol/server-github"
        "@modelcontextprotocol/server-postgres"
        "@modelcontextprotocol/server-memory"
        "@modelcontextprotocol/server-puppeteer"
        "@modelcontextprotocol/server-git"
        "@modelcontextprotocol/server-perplexity"
        "@modelcontextprotocol/server-slack"
        "@modelcontextprotocol/server-notion"
        "@modelcontextprotocol/server-google-drive"
        "@modelcontextprotocol/server-google-maps"
        "@modelcontextprotocol/server-everart"
        "@modelcontextprotocol/server-time"
        "@modelcontextprotocol/server-aws"
        "@modelcontextprotocol/server-reddit"
        "firecrawl-mcp-server"
        "exa-mcp-server"
    )
    
    for server in "${npm_servers[@]}"; do
        log "INFO" "Installing $server..."
        npm install "$server" || warning "Failed to install $server"
    done
    
    # Install Python-based MCP servers (sequential-thinking)
    log "INFO" "Installing sequential-thinking MCP server..."
    if [[ ! -d "sequential-thinking" ]]; then
        git clone https://github.com/sequentialread/sequential-thinking-mcp.git sequential-thinking
        cd sequential-thinking
        uv venv
        source .venv/bin/activate
        uv pip install -e .
        deactivate
        cd ..
    fi
    
    success "MCP servers installed"
}

# Setup git hooks
setup_git_hooks() {
    log "INFO" "Setting up git hooks..."
    
    # Install hooks for the tools directory
    if [[ -d "$HOME_DIR/claude_global_memory/tools/github-repo-manager/commit-hooks" ]]; then
        cd "$HOME_DIR/claude_global_memory/tools/github-repo-manager/commit-hooks"
        chmod +x install-hooks.sh
        ./install-hooks.sh
        success "Git hooks installed"
    else
        warning "Git hooks directory not found, skipping"
    fi
}

# Configure IDE settings
configure_ide() {
    log "INFO" "Configuring IDE settings..."
    
    # Cursor IDE
    if [[ -d "$HOME/.cursor" ]]; then
        log "INFO" "Configuring Cursor IDE..."
        # Copy Cursor-specific settings if provided
        if [[ -f "$SCRIPT_DIR/ide-configs/cursor/settings.json" ]]; then
            mkdir -p "$HOME/.cursor/User"
            cp "$SCRIPT_DIR/ide-configs/cursor/settings.json" "$HOME/.cursor/User/"
            success "Cursor IDE configured"
        fi
    fi
    
    # VS Code
    if [[ -d "$HOME/.vscode" ]] || [[ -d "$HOME/.vscode-server" ]]; then
        log "INFO" "Configuring VS Code..."
        # Copy VS Code-specific settings if provided
        if [[ -f "$SCRIPT_DIR/ide-configs/vscode/settings.json" ]]; then
            mkdir -p "$HOME/.config/Code/User"
            cp "$SCRIPT_DIR/ide-configs/vscode/settings.json" "$HOME/.config/Code/User/"
            success "VS Code configured"
        fi
    fi
}

# Verify installation
verify_installation() {
    log "INFO" "Verifying installation..."
    
    local errors=0
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        warning "Claude CLI not found"
        ((errors++))
    else
        success "Claude CLI verified"
    fi
    
    # Check configurations
    if [[ ! -f "$HOME_DIR/.claude/CLAUDE.md" ]]; then
        warning "SuperClaude framework not found"
        ((errors++))
    else
        success "SuperClaude framework verified"
    fi
    
    if [[ ! -f "$HOME_DIR/.config/claude-code/claude_desktop_config.json" ]]; then
        warning "MCP configuration not found"
        ((errors++))
    else
        success "MCP configuration verified"
    fi
    
    if [[ ! -d "$HOME_DIR/claude_global_memory/knowledge" ]]; then
        warning "Global memory not found"
        ((errors++))
    else
        success "Global memory verified"
    fi
    
    if [[ $errors -eq 0 ]]; then
        success "All components verified successfully!"
        return 0
    else
        warning "Some components failed verification. Please check the warnings above."
        return 1
    fi
}

# Main installation flow
main() {
    echo -e "${BLUE}Claude Code Complete Setup${NC}"
    echo "================================"
    echo
    
    check_wsl
    check_prerequisites
    backup_existing
    install_claude_cli
    copy_configurations
    setup_environment
    install_mcp_servers
    setup_git_hooks
    configure_ide
    
    echo
    echo "================================"
    
    if verify_installation; then
        echo
        echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
        echo
        echo "Next steps:"
        echo "1. Source your shell configuration: source ~/.bashrc"
        echo "2. Set up your API keys in ~/.env.claude (if not using Doppler)"
        echo "3. Test Claude Code: claude --version"
        echo "4. Try a command: claude 'Hello, world!'"
        echo
        echo "For IDE-specific setup, see the docs/ directory."
    else
        echo
        echo -e "${YELLOW}⚠️  Installation completed with warnings${NC}"
        echo "Please address the issues above for full functionality."
    fi
}

# Run main function
main "$@"