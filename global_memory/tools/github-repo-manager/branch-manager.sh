#!/bin/bash
# Branch Management Script for claude-code-wsl-setup
# CRITICAL: Never allows commits to main branch

set -euo pipefail

# Configuration
REPO_PATH="${REPO_PATH:-/home/jb_remus/repos/claude-code-wsl-setup}"
PROTECTED_BRANCHES=("main" "master")
LOG_FILE="/home/jb_remus/claude_global_memory/logs/branch-manager.log"

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Check if current branch is protected
is_protected_branch() {
    local current_branch=$(git -C "$REPO_PATH" branch --show-current)
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$current_branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Ensure not on protected branch
ensure_safe_branch() {
    if is_protected_branch; then
        local safe_branch="work/$(date +%Y%m%d-%H%M%S)"
        log "WARNING" "On protected branch, switching to $safe_branch"
        git -C "$REPO_PATH" checkout -b "$safe_branch"
    fi
}

# Create feature branch
create_feature_branch() {
    local branch_type=$1
    local description=$2
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local branch_name="${branch_type}/${timestamp}-${description}"
    
    log "INFO" "Creating branch: $branch_name"
    
    # Fetch latest changes
    git -C "$REPO_PATH" fetch origin
    
    # Create branch from origin/main
    git -C "$REPO_PATH" checkout -b "$branch_name" origin/main
    
    echo "$branch_name"
}

# Validate branch name
validate_branch_name() {
    local branch_name=$1
    local valid_prefixes=("feature/" "docs/" "fix/" "config/" "update/")
    
    for prefix in "${valid_prefixes[@]}"; do
        if [[ "$branch_name" == "$prefix"* ]]; then
            return 0
        fi
    done
    
    log "ERROR" "Invalid branch name: $branch_name"
    return 1
}

# Safe commit function
safe_commit() {
    local message=$1
    shift
    local files=("$@")
    
    # Ensure not on protected branch
    ensure_safe_branch
    
    # Add files
    for file in "${files[@]}"; do
        git -C "$REPO_PATH" add "$file"
    done
    
    # Commit with message
    git -C "$REPO_PATH" commit -m "$message"
    log "INFO" "Committed: $message"
}

# Safe push function
safe_push() {
    local current_branch=$(git -C "$REPO_PATH" branch --show-current)
    
    # Validate branch name
    if ! validate_branch_name "$current_branch"; then
        log "ERROR" "Cannot push invalid branch: $current_branch"
        return 1
    fi
    
    # Never push to protected branches
    if is_protected_branch; then
        log "ERROR" "BLOCKED: Cannot push to protected branch"
        return 1
    fi
    
    # Push with upstream
    git -C "$REPO_PATH" push -u origin "$current_branch"
    log "INFO" "Pushed branch: $current_branch"
}

# Create pull request
create_pr() {
    local title=$1
    local body=$2
    local labels=${3:-"automated"}
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        log "ERROR" "GitHub CLI (gh) not found"
        return 1
    fi
    
    # Create PR
    gh pr create \
        --repo "arturo-ebuck/claude-code-wsl-setup" \
        --title "$title" \
        --body "$body" \
        --label "$labels" \
        --base main
        
    log "INFO" "Pull request created: $title"
}

# Main workflow function
process_update() {
    local update_type=$1
    local description=$2
    shift 2
    local files=("$@")
    
    log "INFO" "Processing $update_type update: $description"
    
    # Create branch
    local branch_name=$(create_feature_branch "$update_type" "$description")
    
    # Commit changes
    local commit_msg="${update_type}: ${description}"
    safe_commit "$commit_msg" "${files[@]}"
    
    # Push branch
    safe_push
    
    # Create PR
    local pr_body="## Summary
$description

## Files Changed
$(printf '- %s\n' "${files[@]}")

---
*Automated update via branch-manager*"
    
    create_pr "$commit_msg" "$pr_body" "$update_type,automated"
}

# Command line interface
case "${1:-help}" in
    create-branch)
        create_feature_branch "$2" "$3"
        ;;
    commit)
        shift
        safe_commit "$@"
        ;;
    push)
        safe_push
        ;;
    process)
        shift
        process_update "$@"
        ;;
    check)
        if is_protected_branch; then
            echo "WARNING: On protected branch!"
            exit 1
        else
            echo "OK: On safe branch"
        fi
        ;;
    help|*)
        echo "Usage: $0 {create-branch|commit|push|process|check|help}"
        echo ""
        echo "Commands:"
        echo "  create-branch TYPE DESC  - Create a new feature branch"
        echo "  commit MSG FILE...       - Safely commit files"
        echo "  push                     - Push current branch"
        echo "  process TYPE DESC FILE.. - Complete workflow"
        echo "  check                    - Check if on safe branch"
        ;;
esac