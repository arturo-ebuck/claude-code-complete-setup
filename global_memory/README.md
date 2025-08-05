# Claude Global Memory

This directory contains persistent knowledge and context for Claude Code operations on Desktop-02.

## Directory Structure

### `/knowledge/`
Persistent knowledge base containing:
- Technical documentation
- System configurations
- Best practices
- Code patterns and examples
- MCP server status and configurations
- User preferences and requirements
- Desktop-02 setup documentation

### `/projects/`
Project-specific memory and context:
- Project configurations
- Development notes
- Task histories
- Project-specific patterns

### `/tools/`
Custom tools and utilities:
- **GitHub Repository Manager** - Automated workflow with branch protection
  - Autonomous agent for monitoring and committing changes
  - Branch manager for safe operations
  - Git hooks for enforcing best practices
  - Workflow engine for automated PR creation
- Shell scripts
- Python scripts
- Automation tools
- Helper utilities

### `/templates/`
Reusable templates:
- Code templates
- Configuration templates
- Documentation templates
- Script templates

### `/logs/`
Activity and history logs:
- Command history
- Task completion logs
- Error logs
- Performance metrics
- Autonomous agent logs
- Repository manager logs

## Current System Status

### Installed Components
1. **Claude Code CLI** - v1.0.61 (Working)
2. **Doppler CLI** - v3.75.1 (Installed, token refresh needed)
3. **MCP Proxy Infrastructure** - Scripts and configuration ready
4. **GitHub Repository Manager** - Full autonomous workflow system
5. **Global Memory System** - Active and operational

### Active MCP Servers (No API Key Required)
- `filesystem` - File system access
- `memory` - Session memory management
- `git` - Version control operations
- `time` - Date/time utilities
- `docker` - Docker container management
- `puppeteer` - Browser automation

### MCP Servers Awaiting Installation/API Keys
- `sequential-thinking` - Enhanced planning capabilities (pending installation)
- `superclaude` - Comprehensive framework (pending installation)
- `firecrawl` - Advanced web scraping (requires FIRECRAWL_API_KEY)
- `exa` - Neural search (requires EXA_API_KEY)
- `github` - GitHub integration (requires GITHUB_TOKEN via Doppler)
- `perplexity` - AI search (requires PERPLEXITY_API_KEY)
- Various cloud services (AWS, Google Drive, etc.)

## Usage Guidelines

1. **Knowledge Management**: Store important information in the appropriate subdirectory
2. **Project Context**: Create subdirectories in `/projects/` for each major project
3. **Tool Development**: Place custom scripts and tools in `/tools/` with documentation
4. **Template Library**: Build a library of reusable templates in `/templates/`
5. **Log Retention**: Logs are automatically managed and rotated

## OD/UF Policy

This entire directory tree is marked as **OD (Open Directory)**, meaning:
- Claude can freely read and write to all subdirectories
- All files within are considered **UF (User Files)** and can be modified
- This provides a persistent memory across Claude sessions

## Integration with Claude Code

Claude Code will automatically:
- Check this directory for relevant context
- Store learned patterns and solutions
- Reference previous project work
- Maintain activity logs
- Execute autonomous workflows through the GitHub Repository Manager
- Follow user preferences for automation

## File Organization (FHS Compliance)

Following Linux Filesystem Hierarchy Standard:
- Config files: `~/.config/claude-code/`
- Data files: `~/.local/share/claude-code/`
- Cache: `~/.cache/claude-code/`
- Global memory: `~/claude_global_memory/`

## Critical User Preferences

- **NO MANUAL COMMANDS**: All operations must be autonomous
- **Branch Protection**: Main branch is strictly protected
- **Auto-start Required**: Services must start automatically
- **FHS Compliance**: Proper file organization mandatory

## Last Updated
2025-07-29 by jb_remus