# Manual Setup Guide

If you prefer to set up Claude Code manually or need to customize the installation, follow these steps.

## Step 1: Install Prerequisites

```bash
# Update package list
sudo apt update

# Install Git
sudo apt install -y git

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python
sudo apt install -y python3 python3-pip python3-venv

# Install UV (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"
```

## Step 2: Install Claude Code CLI

```bash
npm install -g @anthropic/claude-code-cli
```

## Step 3: Create Directory Structure

```bash
# Create all necessary directories
mkdir -p ~/.claude
mkdir -p ~/.config/claude-code
mkdir -p ~/claude_global_memory/{knowledge,tools,projects,templates,logs}
mkdir -p ~/claude-code-desktop02-setup/{mcp-servers,scripts,config}
```

## Step 4: Copy Configuration Files

### SuperClaude Framework
Copy all `.md` files from `config/claude/` to `~/.claude/`:
- CLAUDE.md
- COMMANDS.md
- FLAGS.md
- PRINCIPLES.md
- RULES.md
- MCP.md
- PERSONAS.md
- ORCHESTRATOR.md
- MODES.md

### MCP Configuration
Copy `config/claude-code/claude_desktop_config.json` to `~/.config/claude-code/`

### Global Memory
Copy the entire contents of `global_memory/` to `~/claude_global_memory/`

## Step 5: Set Up Environment Variables

```bash
# Copy environment template
cp .env.example ~/.env.claude

# Edit with your API keys
nano ~/.env.claude

# Add to .bashrc
echo '[[ -f ~/.env.claude ]] && source ~/.env.claude' >> ~/.bashrc
source ~/.bashrc
```

## Step 6: Install MCP Servers

### NPM-based servers
```bash
cd ~/claude-code-desktop02-setup/mcp-servers
npm init -y

# Install all servers
npm install @modelcontextprotocol/server-filesystem \
            @modelcontextprotocol/server-github \
            @modelcontextprotocol/server-postgres \
            @modelcontextprotocol/server-memory \
            @modelcontextprotocol/server-puppeteer \
            @modelcontextprotocol/server-git \
            @modelcontextprotocol/server-perplexity \
            @modelcontextprotocol/server-slack \
            @modelcontextprotocol/server-notion \
            @modelcontextprotocol/server-google-drive \
            @modelcontextprotocol/server-google-maps \
            @modelcontextprotocol/server-everart \
            @modelcontextprotocol/server-time \
            @modelcontextprotocol/server-aws \
            @modelcontextprotocol/server-reddit \
            firecrawl-mcp-server \
            exa-mcp-server
```

### Python-based servers
```bash
# Sequential-thinking
git clone https://github.com/sequentialread/sequential-thinking-mcp.git sequential-thinking
cd sequential-thinking
uv venv
source .venv/bin/activate
uv pip install -e .
deactivate
cd ..
```

## Step 7: Set File Permissions

```bash
# Secure sensitive files
chmod 600 ~/.config/claude-code/claude_desktop_config.json
chmod 700 ~/claude_global_memory

# Make scripts executable
find ~/claude_global_memory/tools -name "*.sh" -exec chmod +x {} \;
```

## Step 8: Install Git Hooks

```bash
cd ~/claude_global_memory/tools/github-repo-manager/commit-hooks
chmod +x install-hooks.sh
./install-hooks.sh
```

## Step 9: Verify Installation

```bash
# Check Claude CLI
claude --version

# Test MCP server
claude mcp list

# Test basic functionality
claude "Hello, world!"
```

## Customization Options

### Custom MCP Servers
Edit `~/.config/claude-code/claude_desktop_config.json` to add custom servers.

### Custom Memory Content
Add your own documentation to `~/claude_global_memory/knowledge/`

### IDE-Specific Settings
See the `ide-configs/` directory for IDE-specific configurations.

## Troubleshooting

If you encounter issues:
1. Check all paths are correct
2. Verify file permissions
3. Ensure all dependencies are installed
4. Check environment variables are set
5. See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)