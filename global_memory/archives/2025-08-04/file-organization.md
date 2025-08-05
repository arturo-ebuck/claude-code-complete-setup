# File Organization - FHS Compliance

## Overview
This document details the file organization structure for Claude Code on Desktop-02, following the Linux Filesystem Hierarchy Standard (FHS) for proper system integration.

## Directory Structure

### User Home Directory
```
/home/jb_remus/
├── .claude/                           # Claude-specific configuration
│   └── CLAUDE.md                      # User's global instructions
├── .config/                           # User configuration (FHS)
│   └── claude-code/                   # Claude Code configs (future)
├── .local/                            # User-specific data (FHS)
│   └── share/                         
│       └── claude-code/               # Claude Code data (future)
├── .cache/                            # User cache (FHS)
│   └── claude-code/                   # Claude Code cache (future)
├── claude_global_memory/              # Persistent memory system
│   ├── knowledge/                     # Documentation and guides
│   ├── projects/                      # Project-specific memory
│   ├── tools/                         # Custom tools and scripts
│   ├── templates/                     # Reusable templates
│   └── logs/                          # Activity logs
└── claude-code-desktop02-setup/       # Main setup directory
    ├── mcp-servers/                   # MCP server installations
    ├── mcp-proxy/                     # MCP proxy system
    ├── scripts/                       # Setup and test scripts
    ├── config/                        # Configuration files
    └── docs/                          # Documentation
```

### FHS Compliance Status

| Directory | Purpose | FHS Location | Status |
|-----------|---------|--------------|--------|
| Configuration | User settings | `~/.config/claude-code/` | 🔄 Planned |
| Data Files | Application data | `~/.local/share/claude-code/` | 🔄 Planned |
| Cache | Temporary data | `~/.cache/claude-code/` | 🔄 Planned |
| Logs | Activity logs | `~/.local/state/claude-code/` | 🔄 Planned |
| Global Memory | Persistent data | `~/claude_global_memory/` | ✅ Active |

### Current File Locations

#### Configuration Files
- **Claude Instructions**: `/home/jb_remus/.claude/CLAUDE.md`
- **MCP Configuration**: `/home/jb_remus/claude-code-desktop02-setup/claude_desktop_config_enhanced.json`
- **Doppler Config**: `/home/jb_remus/.doppler/.doppler.yaml`
- **Git Config**: `/home/jb_remus/.gitconfig`

#### Tools and Scripts
- **GitHub Repo Manager**: `/home/jb_remus/claude_global_memory/tools/github-repo-manager/`
- **MCP Proxy Scripts**: `/home/jb_remus/claude-code-desktop02-setup/mcp-proxy/bin/`
- **Setup Scripts**: `/home/jb_remus/claude-code-desktop02-setup/scripts/`

#### Logs and Data
- **Agent Logs**: `/home/jb_remus/claude_global_memory/logs/`
- **MCP Proxy Logs**: `/home/jb_remus/claude-code-desktop02-setup/mcp-proxy/logs/`
- **Knowledge Base**: `/home/jb_remus/claude_global_memory/knowledge/`

### OD/UF Classification

#### Open Directories (OD)
Directories Claude can freely access and modify:
- `/home/jb_remus/claude_global_memory/`
- `/home/jb_remus/.claude/`
- `/home/jb_remus/claude-code-desktop02-setup/`
- `/mnt/c/Admin-Tools_JB/` (Windows mount)

#### User Files (UF)
File types Claude can read/modify:
- `*.md` - Markdown documentation
- `*.txt` - Text files
- `*.py` - Python scripts
- `*.sh` - Shell scripts
- `*.json` - JSON configuration
- `*.yaml`, `*.yml` - YAML files

### Migration Plan (Future)

To achieve full FHS compliance:

1. **Configuration Migration**
   ```bash
   # Move configs to ~/.config/claude-code/
   mkdir -p ~/.config/claude-code
   # Future: Move claude_desktop_config.json here
   ```

2. **Data Migration**
   ```bash
   # Create data directory structure
   mkdir -p ~/.local/share/claude-code/{memory,tools,templates}
   # Future: Symlink or move global memory
   ```

3. **Cache Setup**
   ```bash
   # Create cache directory
   mkdir -p ~/.cache/claude-code
   # Future: Use for temporary files
   ```

4. **Log Migration**
   ```bash
   # Create state directory for logs
   mkdir -p ~/.local/state/claude-code
   # Future: Move logs here
   ```

### Best Practices

1. **Never scatter files** in random locations
2. **Use symlinks** for backward compatibility during migration
3. **Document all paths** in configuration files
4. **Follow XDG Base Directory** specification
5. **Maintain OD/UF compliance** for Claude access

### Environment Variables

Future FHS-compliant setup will use:
```bash
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"
```

### Current Working Directories

As configured in CLAUDE.md:
```yaml
working_directories:
  - /mnt/c/Admin-Tools_JB
  - /home/jb_remus/
```

### Important Notes

- The current setup is functional but not fully FHS-compliant
- Migration to FHS structure is planned but not critical
- All current paths are documented and accessible
- No files should be created outside documented locations
- The global memory system remains at `~/claude_global_memory/` for consistency