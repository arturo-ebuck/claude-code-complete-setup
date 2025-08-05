# CRITICAL: Branch Protection Rules

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

### If Main Commit Attempted

1. **Immediate Actions**:
   - Operation blocked
   - Error logged
   - Automatic branch switch
   - User notified

2. **Recovery**:
   ```bash
   # Switch to safe branch
   git checkout -b feature/recovery-$(date +%Y%m%d-%H%M%S)
   
   # Continue work on feature branch
   ```

### Configuration Lock

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

### Monitoring

- All attempts to commit to main are logged
- Repeated attempts trigger alerts
- Audit trail maintained

### Remember

> **The main branch is protected for a reason. It represents stable, reviewed code. All changes, no matter how small, must go through the proper workflow.**

This is not a suggestion—it's a requirement hardcoded into the system at multiple levels.