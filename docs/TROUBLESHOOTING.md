# Troubleshooting Guide

## Common Issues and Solutions

### 1. Permission Denied Errors

**Symptom**: "Permission denied" when running scripts or accessing files

**Solution**:
```bash
# Fix script permissions
chmod +x setup.sh update.sh

# Fix configuration permissions
chmod 600 ~/.config/claude-code/claude_desktop_config.json
chmod -R 700 ~/claude_global_memory

# Fix ownership
sudo chown -R $USER:$USER ~/.claude ~/.config/claude-code ~/claude_global_memory
```

### 2. Claude Command Not Found

**Symptom**: `claude: command not found`

**Solution**:
```bash
# Reinstall Claude CLI
npm install -g @anthropic/claude-code-cli

# Check npm global bin path
npm config get prefix

# Add to PATH if needed
export PATH="$(npm config get prefix)/bin:$PATH"
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3. MCP Server Connection Issues

**Symptom**: "MCP server not responding" or "Failed to connect to server"

**Solution**:
```bash
# Restart Claude Code
claude restart

# Check server logs
claude mcp logs [server-name]

# Verify server installation
cd ~/claude-code-desktop02-setup/mcp-servers
npm list

# Reinstall problematic server
npm uninstall [server-name]
npm install [server-name]
```

### 4. Environment Variables Not Working

**Symptom**: API keys not being recognized

**Solution**:
```bash
# Check if variables are set
echo $GITHUB_TOKEN

# Re-source environment
source ~/.env.claude
source ~/.bashrc

# Verify in claude config
grep -n "GITHUB_TOKEN" ~/.config/claude-code/claude_desktop_config.json
```

### 5. Sequential-Thinking Server Issues

**Symptom**: Sequential-thinking MCP not working

**Solution**:
```bash
cd ~/claude-code-desktop02-setup/mcp-servers/sequential-thinking

# Check Python environment
source .venv/bin/activate
python --version
pip list

# Reinstall
deactivate
rm -rf .venv
uv venv
source .venv/bin/activate
uv pip install -e .
```

### 6. Git Hooks Not Working

**Symptom**: Can commit to main branch

**Solution**:
```bash
# Check hooks are installed
ls -la .git/hooks/

# Reinstall hooks
cd ~/claude_global_memory/tools/github-repo-manager/commit-hooks
./install-hooks.sh

# Verify hook permissions
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

### 7. Doppler Authentication Issues

**Symptom**: Doppler login fails in WSL2

**Solution**:
```bash
# WSL2 has keyring limitations, use environment variables instead
# Add to ~/.env.claude:
export GITHUB_TOKEN="your_token_here"
export PERPLEXITY_API_KEY="your_key_here"
# etc...

# Or use Doppler with manual token
doppler configure set token "your_doppler_token"
```

### 8. High Memory Usage

**Symptom**: System becomes slow when using Claude Code

**Solution**:
```bash
# Check memory usage
free -h
ps aux | grep claude

# Limit concurrent MCP servers
# Edit ~/.config/claude-code/claude_desktop_config.json
# Comment out unused servers

# Restart Claude Code
claude restart
```

### 9. IDE Integration Not Working

**Symptom**: Claude Code not recognized in IDE

**Solution for Cursor**:
```bash
# Restart Cursor completely
pkill cursor

# Clear Cursor cache
rm -rf ~/.cursor/Cache
```

**Solution for VS Code**:
```bash
# Install extension
code --install-extension anthropic.claude-code

# Reload window
# Press Ctrl+Shift+P -> "Developer: Reload Window"
```

### 10. Update Script Fails

**Symptom**: update.sh encounters errors

**Solution**:
```bash
# Run with verbose output
bash -x update.sh

# Update manually
cd ~/claude-code-complete-setup
git pull
./setup.sh
```

## Debug Mode

Enable debug logging:
```bash
export CLAUDE_DEBUG=1
claude --debug "test command"
```

## Getting Help

1. Check Claude Code logs:
   ```bash
   claude logs
   ```

2. Check system logs:
   ```bash
   journalctl -u claude-code --since "1 hour ago"
   ```

3. Run diagnostic:
   ```bash
   claude diagnose
   ```

## Reset Everything

If all else fails, complete reset:
```bash
# Backup current setup
cp -r ~/.claude ~/.claude.backup
cp -r ~/.config/claude-code ~/.config/claude-code.backup
cp -r ~/claude_global_memory ~/claude_global_memory.backup

# Remove everything
rm -rf ~/.claude ~/.config/claude-code ~/claude_global_memory
npm uninstall -g @anthropic/claude-code-cli

# Reinstall from scratch
cd ~/claude-code-complete-setup
./setup.sh
```