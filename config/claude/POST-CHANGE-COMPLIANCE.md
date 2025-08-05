# POST-CHANGE-COMPLIANCE.md - Framework Integrity Verification

**PURPOSE**: Systematic verification checklist to ensure all critical framework components remain operational after changes.

## Compliance Verification Checklist

### ✅ PSA Usage Verification
- [ ] **Memory operations use parallel sub-agents**
  - Verify "review memory" triggers parallel file agents
  - Confirm auto-delegation for >50 files
  - Check concurrency settings are optimal
- [ ] **Large-scale operations use appropriate delegation**
  - Multi-file operations (>10 files) use parallel agents
  - Directory analysis (>5 dirs) uses parallel directory agents
  - System-wide analysis uses specialized focus agents
- [ ] **Auto-detection triggers functioning**
  - File count thresholds trigger auto-delegation
  - Operation type patterns activate appropriate strategies
  - Resource allocation scales with operation complexity

### ✅ Critical Rules Enforcement
- [ ] **RULES.md compliance active**
  - Read before Write/Edit operations enforced
  - Absolute paths only, no relative paths
  - Validation before execution maintained
  - Framework pattern compliance active
- [ ] **PRINCIPLES.md alignment verified**
  - Evidence-based decision making active
  - Quality gates functioning (8-step validation)
  - Senior developer mindset patterns enforced
  - Security-first approaches maintained
- [ ] **ORCHESTRATOR.md routing operational**
  - Pattern recognition functioning
  - Tool selection logic operational
  - MCP server coordination active
  - Quality gates integrated

### ✅ Memory Integration Verification
- [ ] **CLAUDE.md structure intact**
  - All 8 framework components properly referenced
  - Memory file links functional
  - Auto-loading sequence operational
- [ ] **Memory files accessible**
  - COMMANDS.md patterns working
  - FLAGS.md auto-activation functional
  - PERSONAS.md activation logic active
  - MCP.md server coordination operational
- [ ] **Framework coherence maintained**
  - Cross-component references functional
  - Integration patterns preserved
  - Auto-detection algorithms active

### ✅ Documentation Updates
- [ ] **Changelog updated**
  - Session time recorded (EST)
  - Session title descriptive
  - All changes documented with file paths
  - Key findings captured
  - Context provided
- [ ] **Change impact assessed**
  - Breaking changes identified
  - Dependency impacts evaluated
  - Performance implications noted
  - Security considerations addressed

### ✅ Repository Synchronization
- [ ] **GitHub repo updated**
  - All configuration changes committed
  - Changelog updates pushed
  - New directive files included
  - Commit messages descriptive
- [ ] **Version control integrity**
  - Working directory clean
  - No uncommitted critical changes
  - Backup files preserved
  - History maintains context

### ✅ System Operational Verification
- [ ] **MCP servers functional**
  - Context7 responding correctly
  - Sequential thinking operational
  - Magic UI generation working
  - Playwright automation active
- [ ] **Tool integration verified**
  - Claude Code CLI functional
  - Framework commands operational
  - Auto-activation patterns working
  - Error handling intact
- [ ] **Performance benchmarks met**
  - Response times within targets
  - Resource usage optimized
  - Token efficiency maintained
  - Parallel processing active

## Automated Verification Commands

### Quick Health Check
```bash
# Verify framework loading
/health-check --framework --memory --mcp

# Test PSA activation
/test-psa --memory-review --large-analysis

# Validate tool integration
/validate --tools --mcp --github
```

### Comprehensive Validation
```bash
# Full system verification
/validate-all --comprehensive --report

# Performance benchmark
/benchmark --psa --memory --analysis

# Integration test suite
/test-suite --framework --compliance --operational
```

## Failure Response Procedures

### PSA Enforcement Failures
1. **Immediate**: Review PSA-ENFORCEMENT.md for trigger patterns
2. **Investigate**: Check auto-detection algorithm configuration
3. **Fix**: Update orchestrator routing for parallelizable operations
4. **Verify**: Test with known parallelizable operation

### Memory Integration Failures
1. **Immediate**: Check CLAUDE.md file structure and references
2. **Investigate**: Verify all 8 framework files accessible
3. **Fix**: Restore proper @file references and loading sequence
4. **Verify**: Test memory loading with framework command

### Critical Rule Violations
1. **Immediate**: Review RULES.md compliance mechanisms
2. **Investigate**: Check validation gate integration
3. **Fix**: Restore enforcement mechanisms for critical patterns
4. **Verify**: Test with operations requiring validation

## Success Criteria

### Mandatory Requirements
- ✅ All PSA triggers functional (100% compliance)
- ✅ Memory integration operational (all 8 components)
- ✅ Critical rules enforced (validation gates active)
- ✅ Documentation updated (changelog, GitHub)

### Performance Standards
- ✅ Memory operations 70% faster with PSA
- ✅ Large analysis 40-60% time reduction
- ✅ Framework commands <100ms response time
- ✅ Auto-detection <50ms decision time

### Quality Assurance
- ✅ Zero critical rule bypasses
- ✅ 100% parallelizable operation coverage
- ✅ Complete audit trail maintained
- ✅ Framework coherence preserved

---

**COMPLIANCE STATUS**: Active Verification Required
**LAST UPDATED**: 2025-08-04 EST
**VERIFICATION FREQUENCY**: After every framework change