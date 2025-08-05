#!/bin/bash
# Install git hooks for the repository

set -euo pipefail

HOOKS_DIR="$(dirname "$0")"
REPO_PATH="${1:-/home/jb_remus/repos/claude-code-wsl-setup}"
GIT_HOOKS_DIR="$REPO_PATH/.git/hooks"

echo "Installing git hooks for repository: $REPO_PATH"

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install pre-commit hook
if [[ -f "$HOOKS_DIR/pre-commit" ]]; then
    cp "$HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GIT_HOOKS_DIR/pre-commit"
    echo "✅ Installed pre-commit hook"
else
    echo "❌ pre-commit hook not found"
fi

# Install pre-push hook
if [[ -f "$HOOKS_DIR/pre-push" ]]; then
    cp "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo "✅ Installed pre-push hook"
else
    echo "❌ pre-push hook not found"
fi

# Create commit message template
cat > "$REPO_PATH/.gitmessage" << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Type must be one of the following:
# - feat: A new feature
# - fix: A bug fix
# - docs: Documentation only changes
# - style: Changes that do not affect the meaning of the code
# - refactor: A code change that neither fixes a bug nor adds a feature
# - test: Adding missing tests or correcting existing tests
# - chore: Changes to the build process or auxiliary tools
#
# Scope is optional and can be anything specifying the place of the commit change.
#
# Subject is a short description of the change:
# - use the imperative, present tense: "change" not "changed" nor "changes"
# - don't capitalize the first letter
# - no dot (.) at the end
EOF

# Configure git to use the commit template
git -C "$REPO_PATH" config commit.template .gitmessage

echo ""
echo "✅ Git hooks installation complete!"
echo ""
echo "Hooks installed:"
echo "- pre-commit: Prevents commits to main branch"
echo "- pre-push: Validates branch names and prevents pushing to main"
echo ""
echo "IMPORTANT: These hooks enforce the branch-based workflow"
echo "          and prevent direct commits to the main branch."