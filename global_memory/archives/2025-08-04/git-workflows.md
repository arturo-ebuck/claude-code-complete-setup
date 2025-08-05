# Git Workflows and Automation

## Core Git Principles

### 1. Branch Strategy
- **Main/Master**: Production-ready code only
- **Development**: Integration branch for features
- **Feature Branches**: One feature per branch
- **Hotfix Branches**: Emergency production fixes

### 2. Commit Guidelines
- **Atomic Commits**: One logical change per commit
- **Clear Messages**: Descriptive and consistent
- **Signed Commits**: GPG signing when required
- **Co-authorship**: Include Claude attribution

## Automated Git Workflows

### 1. Intelligent Commit Creation
```bash
# Claude's automated commit workflow
1. git status                    # Check current state
2. git diff                      # Review changes
3. git log --oneline -5         # Check recent commits
4. Analyze changes and create meaningful commit message
5. Stage appropriate files
6. Create commit with proper message format
```

**Commit Message Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

### 2. Branch Management
```bash
# Feature branch workflow
git checkout -b feature/description
# Make changes
git add .
git commit -m "feat: implement new feature"
git push -u origin feature/description
```

**Branch Naming Conventions**:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Emergency fixes
- `release/` - Release preparation
- `docs/` - Documentation updates

### 3. Pull Request Automation
```bash
# Automated PR creation
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

## Related Issues
Closes #123
EOF
)"
```

### 4. Merge Strategies
- **Merge Commit**: Preserve full history
- **Squash and Merge**: Clean linear history
- **Rebase and Merge**: Linear history with individual commits

**Decision Matrix**:
- Feature branches: Squash and merge
- Release branches: Merge commit
- Hotfixes: Rebase and merge

## Git Hooks

### 1. Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for secrets
if git diff --cached --name-only | xargs grep -E "(api_key|password|secret)" 2>/dev/null; then
    echo "Error: Potential secrets detected!"
    exit 1
fi

# Run linting
npm run lint || exit 1

# Run tests
npm test || exit 1
```

### 2. Pre-push Hook
```bash
#!/bin/bash
# .git/hooks/pre-push

# Prevent push to main
protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]; then
    echo "Error: Cannot push directly to main branch"
    exit 1
fi
```

### 3. Commit-msg Hook
```bash
#!/bin/bash
# .git/hooks/commit-msg

# Validate commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: <type>(<scope>): <subject>"
    exit 1
fi
```

## Advanced Git Operations

### 1. Interactive Rebase (Automated)
```bash
# Clean up commit history
git rebase -i HEAD~3 <<EOF
pick abc1234 First commit
squash def5678 Fix typo
reword ghi9012 Update feature
EOF
```

### 2. Cherry-picking
```bash
# Apply specific commits
git cherry-pick <commit-hash>
git cherry-pick --continue
```

### 3. Stash Management
```bash
# Save work in progress
git stash save "WIP: feature implementation"
git stash list
git stash apply stash@{0}
git stash pop
```

### 4. Bisect for Debugging
```bash
# Find problematic commit
git bisect start
git bisect bad HEAD
git bisect good <known-good-commit>
# Test and mark as good/bad
git bisect good/bad
git bisect reset
```

## Repository Maintenance

### 1. Cleanup Operations
```bash
# Remove merged branches
git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d

# Clean up remote tracking
git remote prune origin

# Garbage collection
git gc --aggressive --prune=now
```

### 2. History Rewriting (Careful!)
```bash
# Remove sensitive data
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/sensitive/file' \
  --prune-empty --tag-name-filter cat -- --all
```

### 3. Large File Management
```bash
# Use Git LFS for large files
git lfs track "*.psd"
git add .gitattributes
git lfs migrate import --include="*.psd"
```

## Collaboration Patterns

### 1. Fork and Pull Model
```
1. Fork repository
2. Clone your fork
3. Add upstream remote
4. Create feature branch
5. Push to your fork
6. Create pull request
```

### 2. Shared Repository Model
```
1. Clone shared repository
2. Create feature branch
3. Push branch to origin
4. Create pull request
5. Request reviews
6. Merge after approval
```

### 3. GitFlow Model
```
main
├── develop
│   ├── feature/feature1
│   ├── feature/feature2
│   └── feature/feature3
├── release/1.0.0
└── hotfix/critical-fix
```

## Conflict Resolution

### 1. Merge Conflicts
```bash
# Resolve conflicts
git merge feature-branch
# Edit conflicted files
git add <resolved-files>
git commit
```

### 2. Rebase Conflicts
```bash
# During rebase
git rebase main
# Resolve conflicts
git add <resolved-files>
git rebase --continue
```

### 3. Prevention Strategies
- Keep branches short-lived
- Regularly sync with main
- Communicate with team
- Use feature flags

## Git Aliases

### 1. Useful Aliases
```bash
# ~/.gitconfig
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    hist = log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
```

### 2. Complex Aliases
```bash
# Show branches by last commit
recent = for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
```

## CI/CD Integration

### 1. GitHub Actions
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: npm test
```

### 2. Pre-merge Checks
- Automated testing
- Code review requirements
- Status checks
- Branch protection rules

## Security Best Practices

### 1. Signed Commits
```bash
# Configure GPG signing
git config --global user.signingkey <key-id>
git config --global commit.gpgsign true
```

### 2. Protected Branches
- Require pull request reviews
- Dismiss stale reviews
- Require status checks
- Include administrators

### 3. Secret Scanning
- Enable GitHub secret scanning
- Use .gitignore properly
- Regular audit of commits
- Immediate rotation if exposed

## Troubleshooting

### 1. Common Issues
- **Detached HEAD**: `git checkout -b new-branch`
- **Lost commits**: `git reflog`
- **Wrong branch**: `git cherry-pick`
- **Accidental push**: `git revert`

### 2. Recovery Commands
```bash
# Recover deleted branch
git checkout -b recovered-branch <commit-hash>

# Undo last commit
git reset --soft HEAD~1

# Fix commit message
git commit --amend
```

## Best Practices Summary

1. **Commit Often**: Small, focused commits
2. **Pull Before Push**: Stay synchronized
3. **Review Before Merge**: Code quality matters
4. **Document Changes**: Clear commit messages
5. **Automate Workflows**: Reduce manual errors
6. **Secure Practices**: Sign commits, protect branches
7. **Clean History**: Meaningful commit history

## Last Updated
2025-07-29

## Status
ACTIVE - GIT WORKFLOW GUIDE