# Workflow Patterns for Claude Code

## Core Automation Principles

### 1. Zero Manual Intervention
- **Autonomous Execution**: All workflows must run without user commands
- **Smart Context Detection**: Automatically determine required actions
- **Batch Operations**: Group related tasks for efficiency
- **Error Recovery**: Automatic retry and fallback mechanisms

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

### 2. Code Modification Pattern
```
1. Search for target code
2. Read full context
3. Plan modifications
4. Execute changes
5. Verify results
```

**Best Practices:**
- Always read before editing
- Use MultiEdit for multiple changes
- Preserve exact formatting
- Test changes when possible

### 3. Project Setup Pattern
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

### 4. Debugging Workflow
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

### 5. Git Workflow Automation
```
1. Check repository status
2. Stage appropriate changes
3. Create meaningful commits
4. Push to remote
5. Create pull requests
```

**Automated Steps:**
- Pre-commit hooks for validation
- Automatic commit message generation
- Branch protection enforcement
- PR template usage

### 6. Dependency Management
```
1. Scan for dependency files
2. Check for updates
3. Test compatibility
4. Update safely
5. Document changes
```

**Files to Check:**
- package.json / package-lock.json
- requirements.txt / Pipfile
- go.mod / go.sum
- Gemfile / Gemfile.lock

### 7. Documentation Generation
```
1. Analyze code structure
2. Extract comments and docstrings
3. Generate API documentation
4. Create usage examples
5. Update README files
```

**Automation Tools:**
- Use AST parsing for code analysis
- Template-based generation
- Automatic TOC creation
- Cross-reference linking

### 8. Testing Automation
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

### 9. Performance Optimization
```
1. Profile current performance
2. Identify bottlenecks
3. Implement optimizations
4. Measure improvements
5. Document changes
```

**Tools and Techniques:**
- Code profiling
- Benchmark comparisons
- Memory usage analysis
- Optimization tracking

### 10. Security Scanning
```
1. Scan for vulnerabilities
2. Check dependencies
3. Review permissions
4. Audit secrets
5. Generate report
```

**Automated Checks:**
- Dependency vulnerability scanning
- Secret detection in code
- Permission audits
- Security best practice validation

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

## Automation Tools Integration

### Shell Scripts
- Create reusable scripts in ~/claude_global_memory/tools/
- Use proper error handling
- Make scripts idempotent
- Include help documentation

### Python Automation
- Leverage Python for complex logic
- Use async/await for parallel operations
- Create reusable modules
- Include type hints and documentation

### MCP Server Integration
- Automate MCP server tasks
- Chain multiple MCP operations
- Handle server responses
- Implement retry logic

## Best Practices

### 1. Idempotency
- Workflows should be safely re-runnable
- Check current state before acting
- Avoid duplicate operations
- Clean up on failure

### 2. Progress Tracking
- Use TodoWrite for complex workflows
- Log important milestones
- Provide clear status updates
- Estimate completion time

### 3. Error Handling
- Anticipate common failures
- Provide meaningful error messages
- Implement recovery strategies
- Log errors for debugging

### 4. Performance
- Batch similar operations
- Use parallel execution when possible
- Cache expensive computations
- Monitor execution time

### 5. Documentation
- Document workflow purpose
- Include usage examples
- List prerequisites
- Explain configuration options

## Workflow Templates

Templates available in ~/claude_global_memory/templates/:
- project-setup-workflow.sh
- git-automation-workflow.py
- dependency-update-workflow.sh
- test-automation-workflow.py
- documentation-generation-workflow.sh

## Last Updated
2025-07-29

## Status
ACTIVE - CORE PATTERNS