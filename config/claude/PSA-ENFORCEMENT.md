# PSA-ENFORCEMENT.md - Parallel Sub-Agent Implementation Directive

**CRITICAL DIRECTIVE**: All parallelizable operations MUST use parallel sub-agents for optimal efficiency.

## PSA Mandatory Usage Patterns

### Memory Operations (CRITICAL)
- **"review memory"** → MUST use parallel sub-agents to analyze each memory file simultaneously
- **Memory consolidation** → MUST parallelize file processing and analysis
- **Memory validation** → MUST check all files in parallel for consistency

### Large-Scale Analysis (CRITICAL)
- **Multi-file operations** (>10 files) → MUST use parallel sub-agents
- **Directory analysis** (>5 directories) → MUST use parallel directory agents
- **System-wide analysis** → MUST use specialized focus agents (security, performance, quality, architecture)

### Parallelizable Task Patterns
- **Code review** across multiple files → Parallel file agents
- **Security audit** across system → Parallel security focus agents
- **Performance analysis** across modules → Parallel performance agents
- **Quality assessment** across codebase → Parallel quality agents
- **Documentation review** across docs → Parallel documentation agents

## Auto-Detection Triggers

### File Count Thresholds
- **>50 files**: Auto-enable `--delegate files`
- **>7 directories**: Auto-enable `--delegate folders`
- **Mixed scope**: Auto-enable `--delegate auto`

### Operation Type Triggers
- **Memory review operations**: Always parallel
- **Comprehensive analysis**: Always parallel
- **Multi-domain operations** (>2 domains): Always parallel
- **Complex debugging** (system-wide): Always parallel

## Implementation Commands

### Memory Operations
```bash
# CORRECT: Memory review with parallel agents
/analyze @memory --delegate files --concurrency 8

# INCORRECT: Sequential memory review
/analyze @memory
```

### Multi-File Operations
```bash
# CORRECT: Large codebase analysis
/analyze @codebase --delegate auto --concurrency 12

# INCORRECT: Single-agent large analysis
/analyze @codebase
```

### System Analysis
```bash
# CORRECT: Multi-domain system review
/analyze --focus security,performance,quality --delegate parallel-focus

# INCORRECT: Single-agent system analysis
/analyze --focus security,performance,quality
```

## Compliance Verification

### Pre-Operation Checks
1. **Scope Assessment**: Count files/directories to determine PSA requirement
2. **Operation Type**: Identify if operation is parallelizable
3. **Auto-Activation**: Verify appropriate flags are auto-enabled
4. **Resource Allocation**: Ensure adequate concurrency settings

### Performance Targets
- **Memory review**: 70% time reduction with parallel agents
- **Large analysis**: 40-60% time reduction with appropriate delegation
- **System audits**: 50-80% time reduction with specialized agents

## Enforcement Mechanisms

### Automatic Enforcement
- Auto-detect parallelizable operations
- Auto-enable appropriate delegation flags
- Auto-adjust concurrency based on scope
- Auto-select specialized agent types

### Manual Override Protection
- Block inefficient single-agent patterns for large operations
- Warn when PSA would provide significant benefit
- Suggest optimal delegation strategies
- Prevent resource waste on parallelizable tasks

## Critical Success Factors

1. **Always Parallel for Memory**: Never review memory files sequentially
2. **Scale-Appropriate Delegation**: Match delegation strategy to operation scale
3. **Specialized Agents**: Use domain-specific agents for focused analysis
4. **Resource Optimization**: Balance concurrency with system capacity
5. **Quality Maintenance**: Ensure parallel processing maintains quality standards

---

**ENFORCEMENT STATUS**: Active
**LAST UPDATED**: 2025-08-04 EST
**COMPLIANCE LEVEL**: Mandatory for all parallelizable operations