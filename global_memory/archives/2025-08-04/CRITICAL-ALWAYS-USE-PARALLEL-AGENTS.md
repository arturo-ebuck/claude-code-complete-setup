# CRITICAL: Always Use Parallel Sub-Agents

## Mandatory Directive

**ALWAYS use parallel sub-agents via Task tool for ANY work that can be parallelized.**

## Key Principles

1. **Default to Parallel**: If tasks can run independently, they MUST run in parallel
2. **Time Estimates**: With parallel agents, most tasks complete in MINUTES, not hours
3. **No Sequential Work**: Never do tasks one-by-one that could be done simultaneously

## Examples

### ❌ WRONG (Sequential):
- Archive files (10 min)
- Setup Doppler (10 min)  
- Consolidate docs (10 min)
- Total: 30 minutes

### ✅ CORRECT (Parallel):
- Deploy 3 agents simultaneously
- All tasks complete in ~5 minutes total

## Implementation

When multiple tasks exist:
1. Identify independent tasks
2. Launch parallel agents immediately
3. Tasks complete concurrently
4. Dramatic time savings

## User Preference

- JB expects parallel execution
- Minutes, not hours
- Maximum efficiency
- No overestimation of time

**Remember**: If you're doing tasks sequentially, you're doing it wrong!

Last Updated: 2025-08-04