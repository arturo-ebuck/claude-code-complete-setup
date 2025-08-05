# Tools Directory

This directory contains custom tools and utilities for Claude Code operations.

## Organization
- Place executable scripts directly in this directory
- Create subdirectories for complex tools with multiple files
- Always include documentation for each tool

## Naming Convention
- Use descriptive names (e.g., `backup-projects.sh`, `analyze-logs.py`)
- Include file extensions to indicate script type
- Use hyphens for word separation

## Documentation Requirements
Each tool should have:
1. A header comment explaining its purpose
2. Usage examples
3. Any dependencies or requirements
4. Author and date information

## Example Structure
```
tools/
├── README.md (this file)
├── backup-claude-memory.sh
├── analyze-logs.py
└── project-setup/
    ├── setup.sh
    └── config.yaml
```