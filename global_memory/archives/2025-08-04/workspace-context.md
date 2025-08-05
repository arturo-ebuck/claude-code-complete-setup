# Workspace Context Guidelines

## Global Work Directory Context

When working in: `/home/jb_remus/claude-code-desktop02-setup/mcp-servers/sequential-thinking/`
- **Purpose**: This is JB's chosen directory for global, non-project-specific work
- **Types of Work**: 
  - Claude Code optimizations
  - MCP server configurations
  - Tool upgrades and maintenance
  - General system improvements
- **Important**: This is NOT a project directory - it's a workspace for global tool optimization

## File Organization Principles

### Where Files Should Be Saved

**Global Configurations & Memory**:
- `/home/jb_remus/claude_global_memory/` - All persistent knowledge and documentation
- `/home/jb_remus/.config/claude-code/` - Claude Code configurations
- `/home/jb_remus/.claude/` - Claude framework files

**NOT in Current Directory**:
- Do not save configuration files in the working directory
- Keep the workspace clean - it's just for running commands
- All outputs should go to appropriate Linux-side locations

### Best Practices

1. **Always save to Linux side** (not Windows directories) for:
   - Configuration files
   - Global memory updates
   - System documentation
   - Tool configurations

2. **Project-Specific Work**:
   - May be in Windows directories
   - Follow project's existing structure
   - Respect project conventions

3. **Security & Organization**:
   - Follow OD/UF principles
   - Use FHS-compliant paths
   - Maintain proper permissions
   - Keep sensitive data secured

## Important Technical Notes

### Claude Code CLI Capabilities
- **CAN run from Linux directories** (contrary to user's belief)
- Version: 1.0.67 (npm global package)
- Cross-platform support via Node.js
- Works seamlessly in WSL2 Ubuntu

### User Context
- **User**: jb_remus (layman, not developer)
- **Expectation**: I should challenge technical assumptions
- **Preference**: Autonomous tool usage without manual commands
- **Location**: New York (EST timezone for logs)

## Working Directory Convention

When in the sequential-thinking directory or similar:
1. Recognize it as global optimization workspace
2. Don't save outputs there
3. Use appropriate Linux paths for all saves
4. Keep workspace clean and temporary

Last Updated: 2025-08-04