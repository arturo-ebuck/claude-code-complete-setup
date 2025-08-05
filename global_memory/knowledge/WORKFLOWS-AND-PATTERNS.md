# WORKFLOWS AND PATTERNS

**Last Updated**: 2025-08-04  
**Status**: ACTIVE - CORE PATTERNS  

## Core Automation Principles

### 1. Zero Manual Intervention
- **Autonomous Execution**: All workflows must run without user commands
- **Smart Context Detection**: Automatically determine required actions
- **Batch Operations**: Group related tasks for efficiency
- **Error Recovery**: Automatic retry and fallback mechanisms

### 2. Efficiency and Performance
- **Batch Operations**: Group similar tasks together
- **Parallel Execution**: Run independent tasks simultaneously
- **Smart Caching**: Remember previous results to avoid redundant operations
- **Resource Awareness**: Be mindful of system resources

## Claude Code Best Practices

### Code Search and Analysis Flow
```
Best Practice Flow:
1. Start with broad search (Glob for files, Grep for content)
2. Narrow down to specific files
3. Read full context before making decisions
4. Document findings with absolute paths
```

**DO**:
- Use Glob for finding files by pattern
- Use Grep for searching content
- Read specific files when paths are known
- Provide clear summaries with file locations

**DON'T**:
- Use find or grep commands via Bash
- Read files without purpose
- Make assumptions without verification

### Code Modification Flow
```
Best Practice Flow:
1. Understand the requirement
2. Search for relevant code
3. Read complete context
4. Plan modifications
5. Execute changes
6. Verify results
```

**DO**:
- Use MultiEdit for multiple changes
- Preserve exact formatting and indentation
- Test changes when possible
- Create backups for critical changes

**DON'T**:
- Edit without reading first
- Make partial implementations
- Leave code in broken state
- Ignore error messages

## Common Workflow Patterns

### 1. File Search and Analysis Pattern
```
1. Start broad with Glob/Grep
2. Narrow down with specific paths
3. Read relevant files
4. Analyze and report findings
```

**Example Implementation:**
- Use Glob to find all files of a type
- Grep for specific patterns
- Read files that match criteria
- Summarize findings with file paths

### 2. Project Setup Pattern
```
1. Create directory structure
2. Initialize configuration files
3. Set up dependencies
4. Create initial codebase
5. Configure automation
```

**Automation Tips:**
- Use templates from ~/claude_global_memory/templates/
- Set up git hooks automatically
- Configure CI/CD pipelines
- Create documentation structure

### 3. Debugging Workflow
```
1. Reproduce the issue
2. Gather diagnostic information
3. Analyze logs and errors
4. Identify root cause
5. Implement and test fix
```

**Tools to Use:**
- Grep for error patterns
- Read relevant log files
- Test isolated components
- Document solution

### 4. Git Workflow Automation
```
1. Check repository status (git status)
2. Review changes (git diff)
3. Check recent commits (git log)
4. Analyze changes and create meaningful commit message
5. Stage appropriate files
6. Create commit with proper message format
7. Push to remote
8. Create pull requests
```

**Commit Message Format**:
```
<type>(<scope>): <subject>

<body>

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types**: feat, fix, docs, style, refactor, test, chore

### 5. GitHub Repository Management Workflow

#### Change Detection → Branch Creation → Commit Process → Push and PR

**Safeguards**:
1. **Hard-coded Protection**: Main branch commits blocked at multiple levels
2. **Validation Layers**: Configuration file enforcement, runtime checks, shell script validation, git hook prevention

**Naming Conventions**:
- **Feature Branches**: `feature/{timestamp}-{description}`
- **Documentation**: `docs/{timestamp}-{description}`
- **Bug Fixes**: `fix/{timestamp}-{description}`
- **Configuration**: `config/{timestamp}-{description}`
- **Maintenance**: `update/{timestamp}-{description}`

### 6. Testing Automation
```
1. Identify test files
2. Run test suites
3. Analyze coverage
4. Report results
5. Fix failing tests
```

**Best Practices:**
- Parallel test execution
- Automatic test discovery
- Coverage threshold enforcement
- Result visualization

## Advanced Git Operations

### 1. Branch Management
```bash
# Feature branch workflow
git checkout -b feature/description
# Make changes
git add .
git commit -m "feat: implement new feature"
git push -u origin feature/description
```

### 2. Automated PR creation
```bash
gh pr create \
  --title "feat: Add new feature" \
  --body "$(cat <<EOF
## Summary
- Added new functionality
- Updated tests
- Updated documentation

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### 3. Git Hooks for Safety
```bash
#!/bin/bash
# Pre-commit hook - prevents main branch commits

# Check for secrets
if git diff --cached --name-only | xargs grep -E "(api_key|password|secret)" 2>/dev/null; then
    echo "Error: Potential secrets detected!"
    exit 1
fi

# Prevent push to main
protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]; then
    echo "Error: Cannot push directly to main branch"
    exit 1
fi
```

## Performance Optimization Patterns

### 1. Algorithmic Optimizations
```python
# Inefficient: O(n²)
def find_duplicates_slow(items):
    duplicates = []
    for i in range(len(items)):
        for j in range(i + 1, len(items)):
            if items[i] == items[j] and items[i] not in duplicates:
                duplicates.append(items[i])
    return duplicates

# Efficient: O(n)
def find_duplicates_fast(items):
    seen = set()
    duplicates = set()
    for item in items:
        if item in seen:
            duplicates.add(item)
        seen.add(item)
    return list(duplicates)
```

### 2. Caching Strategies
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
            else:
                del self._cache[key]
        return None
```

### 3. Async Processing
```python
import asyncio
import aiohttp

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

## Error Handling and Debugging

### 1. Systematic Debugging Process
```
1. Reproduce the Issue
   - Identify exact steps
   - Isolate variables
   - Create minimal test case

2. Gather Information
   - Check logs
   - Examine error messages
   - Review recent changes

3. Form Hypothesis
   - What could cause this?
   - What changed recently?
   - Similar past issues?

4. Test Hypothesis
   - Add logging/breakpoints
   - Test in isolation
   - Verify assumptions

5. Fix and Verify
   - Implement solution
   - Test thoroughly
   - Prevent regression
```

### 2. Python Error Handling Pattern
```python
import logging
import traceback

class ApplicationError(Exception):
    def __init__(self, message: str, code: str = None, details: dict = None):
        super().__init__(message)
        self.code = code
        self.details = details or {}

def robust_operation(input_data):
    try:
        result = process_data(input_data)
        return result
    except FileNotFoundError:
        logging.error(f"File not found: {input_data}")
        raise ApplicationError(
            f"File not found: {input_data}",
            code="FILE_NOT_FOUND",
            details={"suggestion": "Check the file path"}
        )
    except Exception as e:
        logging.exception("Unexpected error occurred")
        raise ApplicationError(
            "An unexpected error occurred",
            code="UNKNOWN_ERROR",
            details={"error": str(e)}
        )
```

## Shell Scripting Patterns

### 1. Script Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling
error_handler() {
    local exit_code=$?
    local line_number=$1
    echo "Error occurred in script at line $line_number"
    exit "$exit_code"
}
trap 'error_handler ${LINENO}' ERR

# Main function
main() {
    # Parse arguments and execute
    echo "Processing..."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 2. Safe Operations
```bash
# Function with error checking
safe_copy() {
    local source="$1"
    local destination="$2"
    
    if [[ ! -f "${source}" ]]; then
        echo "Error: Source file '${source}' not found"
        return 1
    fi
    
    if ! cp "${source}" "${destination}"; then
        echo "Error: Failed to copy file"
        return 1
    fi
    
    echo "Successfully copied ${source} to ${destination}"
    return 0
}
```

## Docker Integration Patterns

### 1. Multi-stage Build
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
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### 2. Development Environment
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

## MCP Integration Patterns

### 1. Server Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": ["./mcp-servers/filesystem/index.js"],
      "env": {
        "ALLOWED_DIRECTORIES": "/home/user/projects"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 2. Server Implementation
```typescript
import { Server } from '@modelcontextprotocol/sdk';

const server = new Server({
  name: 'custom-server',
  version: '1.0.0',
});

server.setRequestHandler('tools/list', async () => ({
  tools: [{
    name: 'custom_tool',
    description: 'My custom tool',
    inputSchema: {
      type: 'object',
      properties: {
        input: { type: 'string' }
      }
    }
  }]
}));

server.start();
```

## Workflow Composition

### Sequential Workflows
- Execute tasks in order
- Each step depends on previous
- Fail fast on errors
- Clear progress tracking

### Parallel Workflows
- Execute independent tasks simultaneously
- Gather results when all complete
- Optimize for speed
- Handle partial failures

### Conditional Workflows
- Branch based on conditions
- Skip unnecessary steps
- Dynamic path selection
- Context-aware execution

## Best Practices Summary

### Development
1. **Commit Often**: Small, focused commits
2. **Pull Before Push**: Stay synchronized
3. **Review Before Merge**: Code quality matters
4. **Document Changes**: Clear commit messages
5. **Automate Workflows**: Reduce manual errors

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

### Reliability
1. **Idempotent Operations**: Safe to run multiple times
2. **Error Recovery**: Graceful handling of failures
3. **Data Integrity**: Preserve data consistency
4. **Atomic Changes**: All-or-nothing operations
5. **Monitor Continuously**: Track system health

---
**Implementation Status**: ACTIVE  
**Compliance**: MANDATORY  
**Review Cycle**: Continuous improvement