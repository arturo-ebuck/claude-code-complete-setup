# CRITICAL: Parallel Memory Review Implementation

## The Problem
When user commands "review memory", Claude currently loads 12 memory files sequentially:
- 4 personal consolidated files
- 8 SuperClaude framework files

This violates the CRITICAL RULE: "ALWAYS use parallel sub-agents"

## The Solution - Required Behavior

When user says "review memory", Claude MUST:

1. **Identify all memory files** (12 total from CLAUDE.md)
2. **Deploy parallel sub-agents** via Task tool immediately:
   ```
   - Agent 1: Load SYSTEM-STATUS-AND-SETUP.md
   - Agent 2: Load CRITICAL-RULES-AND-PREFERENCES.md  
   - Agent 3: Load WORKFLOWS-AND-PATTERNS.md
   - Agent 4: Load TOOLS-AND-REFERENCE.md
   - Agent 5: Load SuperClaude files (8 files)
   ```
3. **Aggregate results** in ~5 seconds instead of sequential loading

## Implementation Example

When user says "review memory":

```python
# WRONG - Sequential (slow)
for file in memory_files:
    load_file(file)  # 12 sequential operations

# CORRECT - Parallel (fast)  
Task.create_parallel_agents([
    "Load personal memory files",
    "Load SuperClaude framework files"
])
# All files loaded simultaneously in seconds
```

## Expected Time Savings
- Sequential: ~30-60 seconds
- Parallel: ~5-10 seconds
- **6x faster minimum**

## ENFORCEMENT
This is a CRITICAL directive that overrides default behavior. The Task tool MUST be used for memory review operations to comply with the parallel execution requirement.