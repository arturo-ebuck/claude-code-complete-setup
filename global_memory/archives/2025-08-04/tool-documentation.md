# Claude Code Tool Documentation

## Core Tools Overview

### 1. Bash Tool
**Purpose**: Execute shell commands in a persistent session
**Key Features**:
- Persistent shell session across commands
- Timeout control (up to 10 minutes)
- Automatic output truncation at 30K characters
- Working directory persistence

**Usage Guidelines**:
- Quote paths with spaces: `cd "/path with spaces"`
- Chain commands with `;` or `&&`
- Avoid using `cd`, prefer absolute paths
- Never use interactive commands (-i flags)

**Common Commands**:
```bash
# Check system status
uname -a
pwd
whoami

# Git operations
git status
git log --oneline -10
git diff

# File operations (use dedicated tools instead)
# DON'T: cat file.txt
# DO: Use Read tool
```

### 2. Read Tool
**Purpose**: Read files from the filesystem
**Key Features**:
- Supports text and binary files (images, PDFs)
- Line number display (cat -n format)
- Configurable offset and limit
- Multimodal support for images

**Usage**:
```
Read("/absolute/path/to/file.txt")
Read("/path/to/file.txt", offset=100, limit=50)
```

**Best Practices**:
- Always use absolute paths
- Read entire file by default
- Use offset/limit for large files
- Can read non-existent files (returns error)

### 3. Write Tool
**Purpose**: Create or overwrite files
**Key Features**:
- Complete file overwrite
- Creates directories if needed
- Requires Read before overwriting existing files

**Usage**:
```
Write("/absolute/path/to/file.txt", "content")
```

**Important**:
- ALWAYS prefer Edit/MultiEdit for existing files
- Only create files when explicitly required
- Never create documentation unless requested

### 4. Edit Tool
**Purpose**: Make precise string replacements in files
**Key Features**:
- Exact string matching required
- Preserves indentation
- Single or multiple occurrence replacement
- Atomic operations

**Usage**:
```
Edit("/path/to/file", "old_string", "new_string")
Edit("/path/to/file", "old_string", "new_string", replace_all=True)
```

**Critical Rules**:
- Must Read file first
- old_string must be unique (unless replace_all=True)
- Preserve exact indentation after line numbers
- Never include line number prefix in strings

### 5. MultiEdit Tool
**Purpose**: Multiple edits to a single file
**Key Features**:
- Sequential edit application
- Atomic operation (all or nothing)
- More efficient than multiple Edit calls

**Usage**:
```
MultiEdit("/path/to/file", [
    {"old_string": "foo", "new_string": "bar"},
    {"old_string": "baz", "new_string": "qux", "replace_all": True}
])
```

**Best Practices**:
- Plan edit order carefully
- Earlier edits affect later ones
- Use for multiple changes to same file

### 6. Grep Tool
**Purpose**: Search file contents using ripgrep
**Key Features**:
- Full regex support
- Multiple output modes
- File type filtering
- Context lines support

**Usage**:
```
# Find files containing pattern
Grep("pattern")

# Show matching content
Grep("pattern", output_mode="content")

# Search specific file types
Grep("TODO", type="py")

# With context
Grep("error", output_mode="content", -B=2, -A=2)
```

**Output Modes**:
- `files_with_matches`: File paths only (default)
- `content`: Matching lines with context
- `count`: Match counts per file

### 7. Glob Tool
**Purpose**: Find files by name pattern
**Key Features**:
- Standard glob patterns
- Sorted by modification time
- Efficient for large codebases

**Usage**:
```
Glob("**/*.py")  # All Python files
Glob("src/**/*.js")  # JS files in src/
Glob("**/test_*.py")  # Test files
```

**Patterns**:
- `*`: Any characters (except /)
- `**`: Any directories recursively
- `?`: Single character
- `[abc]`: Character class

### 8. LS Tool
**Purpose**: List directory contents
**Key Features**:
- Requires absolute paths
- Ignore patterns support
- Shows files and directories

**Usage**:
```
LS("/absolute/path")
LS("/path", ignore=["*.pyc", "__pycache__"])
```

**Note**: Prefer Glob/Grep for searching

### 9. WebFetch Tool
**Purpose**: Fetch and analyze web content
**Key Features**:
- Converts HTML to markdown
- AI-powered content analysis
- 15-minute cache
- Automatic HTTPS upgrade

**Usage**:
```
WebFetch("https://example.com", "Extract main points")
WebFetch("https://docs.python.org", "Find asyncio examples")
```

### 10. WebSearch Tool
**Purpose**: Search the web for current information
**Key Features**:
- Current event updates
- Domain filtering
- US-only availability

**Usage**:
```
WebSearch("latest Python 3.12 features")
WebSearch("React hooks", allowed_domains=["reactjs.org"])
```

### 11. TodoWrite Tool
**Purpose**: Track complex multi-step tasks
**Key Features**:
- Task state management
- Priority levels
- Progress tracking

**When to Use**:
- Tasks with 3+ steps
- Complex implementations
- Multiple user requests
- Long-running operations

**Task Structure**:
```
{
    "id": "unique_id",
    "content": "Task description",
    "status": "pending|in_progress|completed",
    "priority": "high|medium|low"
}
```

### 12. NotebookRead Tool
**Purpose**: Read Jupyter notebooks
**Key Features**:
- Read all cells or specific cell
- Shows cell outputs
- Preserves cell structure

**Usage**:
```
NotebookRead("/path/to/notebook.ipynb")
NotebookRead("/path/to/notebook.ipynb", cell_id="cell_123")
```

### 13. NotebookEdit Tool
**Purpose**: Edit Jupyter notebook cells
**Key Features**:
- Replace, insert, or delete cells
- Supports code and markdown cells
- Cell ID based editing

**Usage**:
```
NotebookEdit("/path/notebook.ipynb", "new code", cell_id="123")
NotebookEdit("/path/notebook.ipynb", "# Title", cell_type="markdown", edit_mode="insert")
```

### 14. ExitPlanMode Tool
**Purpose**: Exit planning mode to start coding
**Key Features**:
- Presents plan for user approval
- Transitions from planning to implementation

**Usage**:
```
ExitPlanMode("1. Set up project\n2. Implement feature\n3. Add tests")
```

## Tool Selection Guide

### For Searching:
- **File names**: Use Glob
- **File contents**: Use Grep
- **Known paths**: Use Read directly
- **Directory listing**: Use LS (but prefer Glob/Grep)

### For File Operations:
- **Reading**: Always use Read
- **Creating new**: Use Write (only when necessary)
- **Modifying existing**: Use Edit or MultiEdit
- **Never use**: cat, head, tail via Bash

### For Web Operations:
- **Specific URL**: Use WebFetch
- **General search**: Use WebSearch
- **Prefer MCP tools**: If available (mcp__*)

### For Task Management:
- **Simple tasks**: Direct execution
- **Complex tasks**: Use TodoWrite
- **Planning mode**: Use ExitPlanMode when ready

## Performance Tips

1. **Batch Operations**:
   - Use MultiEdit instead of multiple Edits
   - Read multiple files in parallel
   - Group related searches

2. **Efficient Searching**:
   - Start with Glob for file discovery
   - Use Grep with file type filters
   - Limit output with head_limit

3. **Avoid Redundancy**:
   - Don't re-read unchanged files
   - Cache search results mentally
   - Plan edits before executing

## Common Pitfalls

1. **Path Issues**:
   - Always use absolute paths
   - Quote paths with spaces
   - Verify parent directories exist

2. **Edit Failures**:
   - Ensure unique old_string
   - Preserve exact whitespace
   - Read file before editing

3. **Performance Issues**:
   - Avoid broad recursive searches
   - Use specific file type filters
   - Limit output when possible

## Last Updated
2025-07-29

## Status
ACTIVE - COMPREHENSIVE REFERENCE