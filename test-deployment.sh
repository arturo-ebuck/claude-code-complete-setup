#!/usr/bin/env bash
set -euo pipefail

# Test script for Claude Code deployment
# Run this after setup to verify everything works

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Claude Code Deployment Test"
echo "=========================="
echo

# Test 1: Claude CLI
echo -n "Testing Claude CLI... "
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Installed${NC} ($(claude --version))"
else
    echo -e "${RED}✗ Not found${NC}"
fi

# Test 2: SuperClaude Framework
echo -n "Testing SuperClaude Framework... "
if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ Missing${NC}"
fi

# Test 3: MCP Configuration
echo -n "Testing MCP Configuration... "
if [[ -f "$HOME/.config/claude-code/claude_desktop_config.json" ]]; then
    server_count=$(grep -c '"command":' "$HOME/.config/claude-code/claude_desktop_config.json")
    echo -e "${GREEN}✓ Found${NC} ($server_count servers configured)"
else
    echo -e "${RED}✗ Missing${NC}"
fi

# Test 4: Global Memory
echo -n "Testing Global Memory... "
if [[ -d "$HOME/claude_global_memory/knowledge" ]]; then
    file_count=$(ls -1 "$HOME/claude_global_memory/knowledge/"*.md 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Found${NC} ($file_count knowledge files)"
else
    echo -e "${RED}✗ Missing${NC}"
fi

# Test 5: Git Hooks
echo -n "Testing Git Hooks... "
if [[ -f "$HOME/claude_global_memory/tools/github-repo-manager/commit-hooks/pre-commit" ]]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${YELLOW}⚠ Optional${NC} (not found)"
fi

# Test 6: Environment Variables
echo -n "Testing Environment Variables... "
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    echo -e "${GREEN}✓ Set${NC}"
else
    echo -e "${YELLOW}⚠ Not set${NC} (configure in ~/.env.claude)"
fi

# Test 7: MCP Servers
echo -n "Testing MCP Server Installation... "
if [[ -d "$HOME/claude-code-desktop02-setup/mcp-servers/node_modules" ]]; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
fi

# Test 8: Sequential-Thinking
echo -n "Testing Sequential-Thinking... "
if [[ -d "$HOME/claude-code-desktop02-setup/mcp-servers/sequential-thinking/.venv" ]]; then
    echo -e "${GREEN}✓ Installed${NC}"
else
    echo -e "${YELLOW}⚠ Not installed${NC}"
fi

echo
echo "=========================="
echo "Test Summary"
echo

# Run a simple Claude command
echo "Running test command..."
if command -v claude &> /dev/null; then
    claude "Say 'Hello, Claude Code is working!' in a short response"
else
    echo -e "${RED}Cannot run test - Claude CLI not installed${NC}"
fi

echo
echo "Setup verification complete!"