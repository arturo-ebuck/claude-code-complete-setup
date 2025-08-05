# Claude Code Best Practices

## Core Principles

### 1. Autonomous Operation
- **Zero Manual Commands**: Always execute tasks without requiring user intervention
- **Smart Context Detection**: Understand user intent and act accordingly
- **Proactive Tool Usage**: Use available tools based on conversation context
- **Complete Automation**: From start to finish, handle all steps

### 2. File Management
- **Read Before Edit**: ALWAYS read files before modifying
- **Prefer Editing**: Never create new files when editing existing ones suffices
- **No Proactive Documentation**: Only create docs when explicitly requested
- **Absolute Paths**: Always use absolute paths, never relative

### 3. Efficiency and Performance
- **Batch Operations**: Group similar tasks together
- **Parallel Execution**: Run independent tasks simultaneously
- **Smart Caching**: Remember previous results to avoid redundant operations
- **Resource Awareness**: Be mindful of system resources

## Development Best Practices

### 1. Code Search and Analysis
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

### 2. Code Modification
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

### 3. Project Organization
```
Standard Structure:
/project-root/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
├── config/        # Configuration
├── scripts/       # Utility scripts
└── README.md      # Project overview
```

**DO**:
- Follow established project structure
- Keep related files together
- Use consistent naming conventions
- Maintain clean directory hierarchy

**DON'T**:
- Scatter files randomly
- Mix different concerns
- Use inconsistent naming
- Create deep nesting (>4 levels)

### 4. Git Operations
```
Commit Best Practices:
1. Stage related changes together
2. Write clear, concise commit messages
3. Test before committing
4. Use conventional commit format
```

**Commit Message Format**:
```
type(scope): brief description

Longer explanation if needed

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types**: feat, fix, docs, style, refactor, test, chore

### 5. Error Handling
```
Error Response Pattern:
1. Capture error details
2. Understand root cause
3. Implement fix
4. Verify solution
5. Document for future reference
```

**DO**:
- Provide informative error messages
- Include context and suggestions
- Log errors appropriately
- Implement graceful degradation

**DON'T**:
- Ignore errors silently
- Provide cryptic messages
- Leave systems in error state
- Make assumptions about failures

### 6. Testing Practices
```
Testing Workflow:
1. Write tests for new features
2. Run tests before commits
3. Maintain good coverage
4. Fix broken tests immediately
```

**DO**:
- Write clear test descriptions
- Test edge cases
- Use appropriate assertions
- Keep tests independent

**DON'T**:
- Skip testing
- Write fragile tests
- Ignore test failures
- Couple tests together

### 7. Documentation
```
Documentation Standards:
1. Document why, not just what
2. Keep docs close to code
3. Update docs with code changes
4. Use examples liberally
```

**DO**:
- Write clear README files
- Document complex logic
- Include usage examples
- Keep documentation current

**DON'T**:
- Create docs proactively
- Write obvious comments
- Let docs get stale
- Over-document simple code

### 8. Security Practices
```
Security Checklist:
□ No hardcoded secrets
□ Input validation
□ Safe file operations
□ Secure communications
□ Proper authentication
```

**DO**:
- Use environment variables for secrets
- Validate all inputs
- Follow principle of least privilege
- Keep dependencies updated

**DON'T**:
- Store passwords in code
- Trust user input blindly
- Use deprecated methods
- Ignore security warnings

## Communication Best Practices

### 1. User Interaction
- **Clear Communication**: Explain what you're doing and why
- **Progress Updates**: Keep user informed during long operations
- **Error Explanation**: Clearly explain any issues and solutions
- **No Emojis**: Unless explicitly requested by user

### 2. Result Presentation
- **Structured Output**: Organize information clearly
- **Absolute Paths**: Always provide full paths to files
- **Code Snippets**: Include relevant code in responses
- **Summary First**: Lead with summary, then details

### 3. Task Management
- **Use TodoWrite**: For complex multi-step tasks
- **Track Progress**: Update task status in real-time
- **One Task at a Time**: Only one in_progress task
- **Complete Before Moving**: Finish current task first

## Workflow Optimization

### 1. Planning
- **Understand First**: Fully grasp requirements before acting
- **Plan Approach**: Think through steps before executing
- **Consider Edge Cases**: Anticipate potential issues
- **Verify Assumptions**: Check rather than assume

### 2. Execution
- **Systematic Approach**: Follow logical progression
- **Checkpoint Progress**: Verify each step succeeds
- **Handle Failures**: Have contingency plans
- **Clean Up**: Leave system in good state

### 3. Verification
- **Test Results**: Verify changes work as expected
- **Check Side Effects**: Ensure no unintended consequences
- **Document Changes**: Note what was modified
- **Confirm Success**: Explicitly verify task completion

## Performance Guidelines

### 1. Search Optimization
- **Use Specific Patterns**: Narrow searches when possible
- **Leverage File Types**: Filter by extension
- **Limit Output**: Use head_limit for large results
- **Cache Results**: Remember findings for reuse

### 2. File Operations
- **Batch Changes**: Use MultiEdit over multiple Edits
- **Minimize Reads**: Don't re-read unchanged files
- **Efficient Patterns**: Use most specific tool for task
- **Parallel Operations**: Execute independent tasks together

### 3. Resource Management
- **Monitor Usage**: Be aware of system resources
- **Clean Temporary Files**: Remove when no longer needed
- **Limit Concurrent Operations**: Avoid overwhelming system
- **Optimize Algorithms**: Choose efficient approaches

## Quality Standards

### 1. Code Quality
- **Consistent Style**: Follow project conventions
- **Clear Naming**: Use descriptive names
- **Proper Structure**: Organize code logically
- **Maintainable**: Write code others can understand

### 2. Reliability
- **Idempotent Operations**: Safe to run multiple times
- **Error Recovery**: Graceful handling of failures
- **Data Integrity**: Preserve data consistency
- **Atomic Changes**: All-or-nothing operations

### 3. Maintainability
- **Self-Documenting**: Code should be clear
- **Modular Design**: Separate concerns
- **Version Control**: Track all changes
- **Future-Proof**: Consider evolution

## Continuous Improvement

### 1. Learning
- **Study Patterns**: Learn from successful workflows
- **Analyze Failures**: Understand what went wrong
- **Stay Updated**: Keep knowledge current
- **Share Knowledge**: Document learnings

### 2. Optimization
- **Measure Performance**: Track execution times
- **Identify Bottlenecks**: Find slow operations
- **Implement Improvements**: Optimize workflows
- **Verify Benefits**: Ensure improvements work

### 3. Adaptation
- **User Feedback**: Incorporate suggestions
- **Tool Evolution**: Adapt to new capabilities
- **Best Practice Updates**: Evolve practices
- **Continuous Refinement**: Always improving

## Last Updated
2025-07-29

## Status
ACTIVE - FOUNDATIONAL PRACTICES