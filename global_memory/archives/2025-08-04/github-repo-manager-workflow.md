# GitHub Repository Management Workflow Documentation

## Overview
This document describes the complete workflow and safeguards for the automated GitHub repository management system for `arturo-ebuck/claude-code-wsl-setup`.

## System Architecture

### Components
1. **Workflow Engine** (`workflow-engine.py`)
   - Core automation logic
   - Branch management
   - Commit and PR creation
   - Safety validations

2. **Branch Manager** (`branch-manager.sh`)
   - Shell-based branch operations
   - Quick command-line access
   - Safety checks

3. **Autonomous Agent** (`autonomous-agent.py`)
   - File system monitoring
   - Automatic change detection
   - Workflow triggering

4. **Git Hooks** (`commit-hooks/`)
   - Pre-commit validation
   - Pre-push protection
   - Branch name enforcement

## Workflow Process

### 1. Change Detection
```
File Change → Monitor Detection → Categorization → Queue for Processing
```

### 2. Branch Creation
```
Fetch Latest → Create Feature Branch → Switch to Branch → Validate
```

### 3. Commit Process
```
Stage Files → Validate Message → Check Branch → Create Commit
```

### 4. Push and PR
```
Validate Branch → Push to Remote → Create Pull Request → Log Result
```

## Safeguards

### Branch Protection
1. **Hard-coded Protection**: Main branch commits are blocked at multiple levels
2. **Validation Layers**:
   - Configuration file enforcement
   - Runtime checks in Python
   - Shell script validation
   - Git hook prevention

### Naming Conventions
- **Feature Branches**: `feature/{timestamp}-{description}`
- **Documentation**: `docs/{timestamp}-{description}`
- **Bug Fixes**: `fix/{timestamp}-{description}`
- **Configuration**: `config/{timestamp}-{description}`
- **Maintenance**: `update/{timestamp}-{description}`

### Commit Standards
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Automated validation via pre-commit hooks

## Usage Patterns

### Autonomous Operation
```bash
# Start monitoring
./start-agent.sh

# The agent will:
# - Monitor file changes
# - Create branches automatically
# - Commit changes
# - Create pull requests
```

### Manual Updates
```bash
# Single file update
python3 autonomous-agent.py update "Add new feature" src/feature.py

# Multiple files
python3 autonomous-agent.py update "Update documentation" README.md docs/guide.md

# Using branch manager
./branch-manager.sh process feature "new-functionality" file1.py file2.py
```

### Direct Commands
```bash
# Create branch
./branch-manager.sh create-branch feature "user-authentication"

# Commit files
./branch-manager.sh commit "feat(auth): add login function" auth.py

# Push branch
./branch-manager.sh push
```

## Configuration

### Agent Configuration (`agent-config.yaml`)
- Repository settings
- Branch protection rules
- Workflow automation rules
- Validation settings
- Logging configuration

### Key Settings
```yaml
branch_protection:
  protected_branches: ["main", "master"]
  enforcement_level: strict
  require_pull_request: true

safeguards:
  prevent_main_commit: true  # MUST remain true
  require_branch_prefix: true
  validate_commit_format: true
```

## Error Handling

### Common Scenarios
1. **Attempt to commit to main**
   - Blocked by pre-commit hook
   - Agent switches to safe branch
   - Error logged

2. **Invalid branch name**
   - Validation fails
   - Suggestion provided
   - Operation aborted

3. **Push to protected branch**
   - Pre-push hook blocks
   - Error message displayed
   - Must use PR workflow

## Monitoring and Logs

### Log Locations
- Agent logs: `/home/jb_remus/claude_global_memory/logs/autonomous-agent.log`
- Repository manager: `/home/jb_remus/claude_global_memory/logs/repo-manager.log`
- Branch operations: `/home/jb_remus/claude_global_memory/logs/branch-manager.log`

### Log Rotation
- Daily rotation
- 30-day retention
- Automatic cleanup

## Best Practices

1. **Always Use Branches**
   - Never attempt to bypass branch protection
   - Create descriptive branch names
   - One feature per branch

2. **Commit Messages**
   - Follow conventional format
   - Be descriptive but concise
   - Include scope when relevant

3. **Pull Requests**
   - Review before merging
   - Use labels for categorization
   - Keep PRs focused

4. **Testing**
   - Test changes locally first
   - Ensure no breaking changes
   - Update tests as needed

## Troubleshooting

### Agent Won't Start
```bash
# Check dependencies
pip3 install -r requirements.txt

# Verify permissions
chmod +x *.sh *.py

# Check logs
tail -f /home/jb_remus/claude_global_memory/logs/autonomous-agent.log
```

### Git Hook Issues
```bash
# Reinstall hooks
./commit-hooks/install-hooks.sh /path/to/repo

# Check hook permissions
ls -la .git/hooks/
```

### Branch Problems
```bash
# Check current branch
git branch --show-current

# Switch to safe branch
git checkout -b work/temp

# Clean up old branches
git branch -d old-branch
```

## Security Considerations

1. **Credentials**: Never commit credentials or tokens
2. **File Size**: 10MB limit enforced by hooks
3. **Branch Access**: Only authorized operations
4. **Audit Trail**: All operations logged

## Integration with Claude

This system is designed to work seamlessly with Claude's capabilities:
- File monitoring for automatic updates
- Branch-based workflow enforcement
- Autonomous operation without user intervention
- Comprehensive logging for transparency

The system ensures that all repository updates follow best practices and maintain code quality through automated workflows.

## Current Status (2025-07-29)

### Implementation Status
- ✅ **Workflow Engine** - Fully implemented with safeguards
- ✅ **Branch Manager** - Shell scripts operational
- ✅ **Autonomous Agent** - Python-based monitoring ready
- ✅ **Git Hooks** - Pre-commit and pre-push protection active
- ✅ **Configuration** - YAML-based settings in place

### Active Protections
- **Main branch protection**: Hard-coded at multiple levels
- **Branch naming enforcement**: Automated prefix validation
- **Commit message standards**: Conventional format required
- **File size limits**: 10MB maximum per file
- **Automated PR creation**: Direct pushes blocked

### Repository Target
- **Primary Repo**: `arturo-ebuck/claude-code-wsl-setup`
- **Protection Level**: STRICT (no main branch commits)
- **Workflow**: Feature branches → Pull Requests → Review → Merge

### Recent Updates
- Enhanced safety validations in all components
- Multiple redundant checks for branch protection
- Improved error handling and logging
- Documentation of all safeguards and workflows