#!/usr/bin/env bash
set -euo pipefail

# Claude Code Update Script
# Updates an existing Claude Code installation

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Log function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1: $2"
}

# Success message
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Warning message
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Update Claude CLI
update_claude_cli() {
    log "INFO" "Updating Claude Code CLI..."
    npm update -g @anthropic/claude-code-cli
    success "Claude Code CLI updated to $(claude --version)"
}

# Update configurations
update_configurations() {
    log "INFO" "Updating configurations..."
    
    # Backup current configs
    cp -r "$HOME_DIR/.claude" "$HOME_DIR/.claude.backup.$TIMESTAMP"
    cp -r "$HOME_DIR/.config/claude-code" "$HOME_DIR/.config/claude-code.backup.$TIMESTAMP"
    
    # Update SuperClaude framework
    cp "$SCRIPT_DIR/config/claude/"*.md "$HOME_DIR/.claude/"
    success "Updated SuperClaude framework"
    
    # Update MCP configuration
    cp "$SCRIPT_DIR/config/claude-code/claude_desktop_config.json" "$HOME_DIR/.config/claude-code/"
    success "Updated MCP configuration"
    
    # Update global memory
    rsync -av --exclude='projects/*' --exclude='logs/*' "$SCRIPT_DIR/global_memory/" "$HOME_DIR/claude_global_memory/"
    success "Updated global memory (preserving projects and logs)"
}

# Update MCP servers
update_mcp_servers() {
    log "INFO" "Updating MCP servers..."
    
    cd "$HOME_DIR/claude-code-desktop02-setup/mcp-servers"
    
    # Update npm packages
    npm update
    success "Updated npm-based MCP servers"
    
    # Update sequential-thinking
    if [[ -d "sequential-thinking" ]]; then
        cd sequential-thinking
        git pull
        source .venv/bin/activate
        uv pip install -e . --upgrade
        deactivate
        cd ..
        success "Updated sequential-thinking MCP server"
    fi
}

# Main update flow
main() {
    echo -e "${BLUE}Claude Code Update${NC}"
    echo "=================="
    echo
    
    update_claude_cli
    update_configurations
    update_mcp_servers
    
    echo
    echo "=================="
    echo -e "${GREEN}✅ Update completed successfully!${NC}"
    echo
    echo "Your previous configurations have been backed up with timestamp: $TIMESTAMP"
    echo "Restart any open Claude Code sessions to use the updated version."
}

# Run main function
main "$@"