# TOOLS AND REFERENCE

**Last Updated**: 2025-08-04  
**Status**: ACTIVE - COMPREHENSIVE REFERENCE  

## Claude Code Tool Documentation

### Core Tools Overview

#### 1. Bash Tool
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
# System status
uname -a; pwd; whoami

# Git operations
git status; git log --oneline -10; git diff

# NEVER use for file operations - use dedicated tools
```

#### 2. Read Tool
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

#### 3. Edit Tool
**Purpose**: Make precise string replacements in files
**Key Features**:
- Exact string matching required
- Preserves indentation
- Single or multiple occurrence replacement
- Atomic operations

**Critical Rules**:
- Must Read file first
- old_string must be unique (unless replace_all=True)
- Preserve exact indentation after line numbers
- Never include line number prefix in strings

#### 4. MultiEdit Tool
**Purpose**: Multiple edits to a single file
**Key Features**:
- Sequential edit application
- Atomic operation (all or nothing)
- More efficient than multiple Edit calls

#### 5. Grep Tool
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
```

**Output Modes**:
- `files_with_matches`: File paths only (default)
- `content`: Matching lines with context
- `count`: Match counts per file

#### 6. Glob Tool
**Purpose**: Find files by name pattern
**Usage**:
```
Glob("**/*.py")  # All Python files
Glob("src/**/*.js")  # JS files in src/
```

## Advanced MCP Tools Usage Guide

### Sequential-Thinking MCP (✅ Active)
- **Purpose**: Structured problem-solving through defined cognitive stages
- **Autonomous Usage**: Automatically engages for complex problems
- **Replaces**: Basic memory MCP

### SuperClaude Framework (✅ Installed)
- **Purpose**: Adds 16 specialized commands and smart personas
- **Commands**: Use `/sc:` prefix (e.g., `/sc:implement`, `/sc:analyze`)
- **Autonomous Usage**: Personas activate automatically based on context

**Most Useful Commands**:
- `/sc:implement <feature>` - Build new features
- `/sc:analyze <code/system>` - Deep analysis
- `/sc:troubleshoot <issue>` - Debug problems
- `/sc:design <system>` - Architecture design
- `/sc:improve <code>` - Optimize existing code

### Graphiti (⚠️ Needs Setup)
- **Purpose**: Knowledge graph system for persistent memory
- **Status**: Documented but not in active config
- **Next Step**: Need to install and configure if you want to use it

## Python Patterns and Standards

### Type Hints and Structure
```python
from typing import List, Dict, Optional, Union, Tuple, Any
from dataclasses import dataclass

def process_items(
    items: List[str],
    config: Dict[str, Any],
    timeout: Optional[int] = None
) -> Tuple[List[str], bool]:
    """Process items with configuration."""
    results: List[str] = []
    success: bool = True
    return results, success

@dataclass
class Configuration:
    host: str
    port: int
    debug: bool = False
```

### Error Handling Pattern
```python
class ApplicationError(Exception):
    def __init__(self, message: str, code: str = None, details: dict = None):
        super().__init__(message)
        self.code = code
        self.details = details or {}

def robust_operation():
    try:
        result = risky_operation()
        return result
    except FileNotFoundError as e:
        raise ApplicationError(
            f"File not found: {e}",
            code="FILE_NOT_FOUND",
            details={"suggestion": "Check the file path"}
        )
```

### Async Patterns
```python
import asyncio
import aiohttp

async def fetch_multiple_urls(urls: List[str]) -> List[str]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

## Shell Scripting Best Practices

### Essential Script Header
```bash
#!/usr/bin/env bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'       # Set Internal Field Separator

# Enable debug mode if DEBUG env var is set
[[ "${DEBUG:-0}" == "1" ]] && set -x
```

### Error Handling
```bash
# Custom error handler
error_handler() {
    local line_no=$1
    local bash_lineno=$2
    local last_command=$3
    local code=$4
    echo "Error on line ${line_no}: command '${last_command}' exited with status ${code}"
    exit "${code}"
}

trap 'error_handler ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" $?' ERR
```

### Function Structure
```bash
# Function with documentation
print_color() {
    local color="$1"
    local message="$2"
    
    case "${color}" in
        red)    echo -e "\033[0;31m${message}\033[0m" ;;
        green)  echo -e "\033[0;32m${message}\033[0m" ;;
        *)      echo "${message}"; return 1 ;;
    esac
    return 0
}
```

## Docker Integration Guide

### Multi-stage Build Pattern
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
USER nodejs
CMD ["node", "dist/index.js"]
```

### Development Environment
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

## Performance Optimization Patterns

### Caching Strategies
```python
from functools import lru_cache
import time

@lru_cache(maxsize=128)
def expensive_computation(n: int) -> int:
    time.sleep(1)  # Simulate expensive operation
    return n * n

# Time-based cache
class TTLCache:
    def __init__(self, ttl: int = 300):
        self._cache = {}
        self._ttl = ttl
    
    def get(self, key: str):
        if key in self._cache:
            value, timestamp = self._cache[key]
            if time.time() - timestamp < self._ttl:
                return value
        return None
```

### Database Optimization
```python
# SQLAlchemy optimization
from sqlalchemy.orm import selectinload, joinedload

# Bad: N+1 queries
users = session.query(User).all()
for user in users:
    print(user.orders)  # Each access triggers a query

# Good: Single query with join
users = session.query(User).options(
    joinedload(User.orders)
).all()
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

## Common Debugging Patterns

### Binary Search Debugging
```python
def binary_search_debug(data_list, target_condition):
    left, right = 0, len(data_list) - 1
    
    while left < right:
        mid = (left + right) // 2
        print(f"Testing index {mid}")
        
        if target_condition(data_list[mid]):
            left = mid + 1
        else:
            right = mid
    
    return left
```

### Performance Profiling
```python
import time
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.perf_counter()
    yield
    elapsed = time.perf_counter() - start
    print(f"{name} took {elapsed:.4f} seconds")

# Usage
with timer("Database query"):
    results = db.query("SELECT * FROM large_table")
```

## Security Guidelines

### Input Validation
```bash
validate_input() {
    local input="$1"
    
    # Check for empty input
    if [[ -z "${input}" ]]; then
        echo "Error: Input cannot be empty"
        return 1
    fi
    
    # Check for special characters
    if [[ "${input}" =~ [^a-zA-Z0-9_-] ]]; then
        echo "Error: Input contains invalid characters"
        return 1
    fi
    
    return 0
}
```

### Secure Practices
```bash
# Use quotes to prevent word splitting
rm -rf "${user_input}"  # Always quote variables

# Secure temporary files
temp_file=$(mktemp) || exit 1
trap 'rm -f "${temp_file}"' EXIT

# Restrict permissions
umask 077  # Files created with 600 permissions
```

## Configuration Management

### Settings Validation
```python
from pydantic import BaseSettings, validator

class Settings(BaseSettings):
    app_name: str = "MyApp"
    debug: bool = False
    database_url: str
    
    @validator('database_url')
    def validate_database_url(cls, v):
        if not v.startswith(('postgresql://', 'mysql://', 'sqlite://')):
            raise ValueError('Invalid database URL')
        return v
    
    class Config:
        env_file = '.env'
```

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

## Workspace Context Guidelines

### Global Work Directory Context
When working in: `/home/jb_remus/claude-code-desktop02-setup/mcp-servers/sequential-thinking/`
- **Purpose**: JB's chosen directory for global, non-project-specific work
- **Important**: This is NOT a project directory - it's a workspace for global tool optimization

### File Save Locations
**Global Configurations & Memory**:
- `/home/jb_remus/claude_global_memory/` - All persistent knowledge and documentation
- `/home/jb_remus/.config/claude-code/` - Claude Code configurations
- `/home/jb_remus/.claude/` - Claude framework files

**NOT in Current Directory**:
- Do not save configuration files in the working directory
- Keep the workspace clean - it's just for running commands
- All outputs should go to appropriate Linux-side locations

## Best Practices Summary

### Development
1. **Type Hints**: Always use type hints for clarity
2. **Docstrings**: Document all public functions/classes
3. **Error Handling**: Be specific with exceptions
4. **Testing**: Aim for high test coverage
5. **Code Organization**: Clear module structure

### Performance
1. **Measure First**: Always profile before optimizing
2. **Focus on Bottlenecks**: Optimize the critical 20%
3. **Choose Right Algorithms**: O(n) beats O(n²)
4. **Cache Wisely**: Cache expensive computations
5. **Batch Operations**: Group similar operations

### Security
1. **Validate Inputs**: Sanitize all user inputs
2. **Use Environment Variables**: For sensitive data
3. **Proper Permissions**: 600 for sensitive files
4. **Audit Trail**: Log all significant actions
5. **Regular Updates**: Keep dependencies current

### Shell Scripting
1. **Always use `set -euo pipefail`**
2. **Quote all variables: `"${var}"`**
3. **Use `shellcheck` for validation**
4. **Prefer `[[ ]]` over `[ ]` in bash**
5. **Add error handling and logging**

---
**Reference Status**: COMPREHENSIVE  
**Update Frequency**: As tools evolve  
**Compliance**: Follow for optimal results