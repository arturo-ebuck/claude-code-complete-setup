# CRITICAL RULES AND PREFERENCES

**Status**: ACTIVE - MUST FOLLOW  
**Last Updated**: 2025-08-04  
**Compliance**: MANDATORY - NO EXCEPTIONS  

## ABSOLUTE RULE: NEVER COMMIT TO MAIN

This document contains **CRITICAL** instructions that **MUST** be followed without exception.

### Hard-Coded Rules

1. **Main Branch is Sacred**
   - The `main` branch must NEVER receive direct commits
   - All changes MUST go through feature branches
   - Pull requests are REQUIRED for all changes

2. **Enforcement Levels**
   - Configuration: `prevent_main_commit: true` (NEVER change)
   - Code: Multiple validation checks
   - Git Hooks: Pre-commit and pre-push blocks
   - Runtime: Automatic branch switching

3. **No Exceptions**
   - Emergency fixes: Use `fix/` branches
   - Quick updates: Use `update/` branches
   - Documentation: Use `docs/` branches
   - ALL changes require branches

### Implementation Checks

```python
# Python validation (workflow-engine.py)
if current_branch in ['main', 'master']:
    raise ValueError("BLOCKED: Cannot commit to protected branch")

# Shell validation (branch-manager.sh)
if is_protected_branch; then
    log "ERROR" "BLOCKED: Cannot push to protected branch"
    return 1
fi

# Git hook validation (pre-commit)
if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo "❌ ERROR: Direct commits to main are not allowed!"
    exit 1
fi
```

## CRITICAL: Always Use Parallel Sub-Agents

**ALWAYS use parallel sub-agents via Task tool for ANY work that can be parallelized.**

### Key Principles

1. **Default to Parallel**: If tasks can run independently, they MUST run in parallel
2. **Time Estimates**: With parallel agents, most tasks complete in MINUTES, not hours
3. **No Sequential Work**: Never do tasks one-by-one that could be done simultaneously

### MANDATORY: Parallel Memory Review
When user commands "review memory":
- **MUST** use Task tool to load all memory files in parallel
- **NEVER** load files sequentially
- Deploy agents for: Personal files (4) + SuperClaude files (8)
- Expected: 6x faster (5-10 seconds vs 30-60 seconds)

### Examples

#### ❌ WRONG (Sequential):
- Archive files (10 min)
- Setup Doppler (10 min)  
- Consolidate docs (10 min)
- Total: 30 minutes

#### ✅ CORRECT (Parallel):
- Deploy 3 agents simultaneously
- All tasks complete in ~5 minutes total

### Implementation

When multiple tasks exist:
1. Identify independent tasks
2. Launch parallel agents immediately
3. Tasks complete concurrently
4. Dramatic time savings

**Remember**: If you're doing tasks sequentially, you're doing it wrong!

## Command Execution Preference - CRITICAL

**STRICT RULE**: User does NOT want to remember or execute commands manually.

- Claude must autonomously call all tools based on conversation context
- No manual command execution should be required from user
- If manual intervention is unavoidable, must explain why and provide simplest solution

### Global Memory Requirements
- This preference is HARD-CODED and must ALWAYS be followed
- Any deviations require explicit explanation and justification
- Simplification strategies must be provided when automation isn't possible

## File Management Rules

### Core Principles
- **Read Before Edit**: ALWAYS read files before modifying
- **Prefer Editing**: Never create new files when editing existing ones suffices
- **No Proactive Documentation**: Only create docs when explicitly requested
- **Absolute Paths**: Always use absolute paths, never relative

### NEVER Create Files Unless Required
- ALWAYS prefer editing existing files
- NEVER proactively create documentation files (*.md) or README files
- Only create documentation files if explicitly requested by User

## Security Guidelines - MANDATORY

### File Access Control
- **OD/UF Policy**: Strictly follow Open Directory and User Files policy
- **Path Validation**: Always validate file paths before operations
- **Absolute Paths**: Use absolute paths to avoid directory traversal attacks
- **Permission Checks**: Verify file permissions before modifications

### Sensitive Information Handling
- **Never Store**: API keys, passwords, or tokens in plain text files
- **Use Doppler**: Leverage Doppler for secure secret management (when available)
- **Environment Variables**: Access secrets via environment variables only
- **Git Ignore**: Ensure .gitignore excludes all sensitive files

### Command Execution Safety
- **Input Validation**: Sanitize all user inputs before command execution
- **Avoid Shell Injection**: Use parameterized commands, never string concatenation
- **Timeout Limits**: Apply reasonable timeouts to prevent hanging processes
- **Error Handling**: Catch and handle command failures gracefully

## File Organization - FHS Compliance

### Directory Structure Requirements
- **Config files**: `~/.config/claude-code/`
- **Data files**: `~/.local/share/claude-code/`
- **Cache**: `~/.cache/claude-code/`
- **Global memory**: `~/claude_global_memory/`
- **Never scatter files** in random locations

### OD/UF Classification

#### Open Directories (OD) - Claude can freely access and modify:
- `/home/jb_remus/claude_global_memory/`
- `/home/jb_remus/.claude/`
- `/home/jb_remus/claude-code-desktop02-setup/`
- `/mnt/c/Admin-Tools_JB/` (Windows mount)

#### User Files (UF) - File types Claude can read/modify:
- `*.md` - Markdown documentation
- `*.txt` - Text files
- `*.py` - Python scripts
- `*.sh` - Shell scripts
- `*.json` - JSON configuration
- `*.yaml`, `*.yml` - YAML files

## GitHub Workflow Preferences - ENFORCED

- **NEVER commit directly to main branch** - Use feature branches only
- **Automated PR creation** preferred over manual git commands
- **Branch protection is mandatory** - Multiple safeguards must be active
- **Use autonomous agent** for routine commits and updates

### Workflow Requirements

1. **Every Change**:
   ```
   Create Branch → Make Changes → Commit → Push → Create PR
   ```

2. **Branch Naming**:
   - MUST use approved prefixes
   - MUST include timestamp
   - MUST be descriptive

3. **Validation**:
   - Automatic on every operation
   - Cannot be disabled
   - Logs all attempts

## Tool Integration Rules - MANDATORY

1. All new tools MUST be tested before declaring them functional
2. Tools should work autonomously without user commands
3. Auto-start configurations required for all services

## Error Handling Requirements

- **Fail gracefully** - Provide clear error messages
- **Suggest alternatives** - When automation fails, offer simplest manual option
- **Log everything** - Maintain audit trail for debugging
- **Never ignore errors** - Address or escalate all issues

## Communication Style Requirements

- **Be explicit about limitations** - When automation isn't possible
- **Provide status updates** - During long operations
- **Use clear language** - Avoid jargon unless necessary
- **Confirm understanding** - Verify requirements before acting
- **No Emojis**: Unless explicitly requested by user

## Configuration Lock - NEVER CHANGE

The following settings are **LOCKED** and must **NEVER** be changed:

```yaml
branch_protection:
  protected_branches: ["main", "master"]  # DO NOT MODIFY
  enforcement_level: strict               # DO NOT MODIFY
  require_pull_request: true             # DO NOT MODIFY

safeguards:
  prevent_main_commit: true              # CRITICAL: NEVER SET TO FALSE
  require_branch_prefix: true            # DO NOT MODIFY
  validate_commit_format: true           # DO NOT MODIFY
```

## Monitoring

- All attempts to commit to main are logged
- Repeated attempts trigger alerts
- Audit trail maintained

## Emergency Procedures

If security breach suspected:
1. Stop all operations immediately
2. Revoke compromised credentials
3. Document the incident
4. Notify appropriate parties
5. Review and update security measures

## Remember

> **The main branch is protected for a reason. It represents stable, reviewed code. All changes, no matter how small, must go through the proper workflow.**

This is not a suggestion—it's a requirement hardcoded into the system at multiple levels.

---
**Compliance Level**: MANDATORY  
**Enforcement**: AUTOMATIC  
**Violations**: BLOCKED AT MULTIPLE LEVELS