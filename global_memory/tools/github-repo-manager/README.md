# GitHub Repository Management System for claude-code-wsl-setup

## Overview
This automated agent manages the `arturo-ebuck/claude-code-wsl-setup` repository with strict branch-based workflows and autonomous operation capabilities.

## Core Principles
1. **NEVER commit directly to main branch** - All changes must go through feature branches
2. **Automated branch creation** for all updates
3. **Clear naming conventions** for branches
4. **Autonomous operation** without user intervention
5. **Comprehensive logging** of all operations

## Agent Configuration

### Repository Details
- **Repository**: arturo-ebuck/claude-code-wsl-setup
- **Primary Branch**: main (protected)
- **Work Branches**: feature/*, docs/*, fix/*, config/*

### Branch Strategy
- `feature/*` - New features and enhancements
- `docs/*` - Documentation updates
- `fix/*` - Bug fixes and corrections
- `config/*` - Configuration changes
- `update/*` - Dependency and maintenance updates

## Workflow Components

### 1. Branch Management
- Automatic branch creation based on change type
- Branch naming follows pattern: `{type}/{timestamp}-{description}`
- Example: `feature/20250729-add-mcp-integration`

### 2. Commit Standards
- Conventional commit format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Automated commit message generation

### 3. Pull Request Automation
- Auto-generated PR descriptions
- Labels assigned based on change type
- Draft PRs for work in progress

## Safety Mechanisms

### Branch Protection Rules
1. Main branch requires pull request reviews
2. No force pushes allowed
3. Status checks must pass
4. Branch must be up-to-date before merge

### Validation Checks
1. Pre-commit validation
2. File integrity verification
3. Configuration syntax validation
4. Documentation link checking

## Implementation Files
- `agent-config.yaml` - Main agent configuration
- `workflow-engine.py` - Workflow automation engine
- `branch-manager.sh` - Branch management scripts
- `pr-template.md` - Pull request template
- `commit-hooks/` - Git hooks for validation

## Usage Instructions
See individual component documentation for detailed usage.