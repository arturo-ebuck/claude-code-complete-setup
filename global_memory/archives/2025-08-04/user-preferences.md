# User Preferences - CRITICAL

## Command Execution Preference
**STRICT RULE**: User does NOT want to remember or execute commands manually.
- Claude must autonomously call all tools based on conversation context
- No manual command execution should be required from user
- If manual intervention is unavoidable, must explain why and provide simplest solution

## Global Memory Requirements
- This preference is HARD-CODED and must ALWAYS be followed
- Any deviations require explicit explanation and justification
- Simplification strategies must be provided when automation isn't possible

## Tool Integration Rules
1. All new tools MUST be tested before declaring them functional
2. Tools should work autonomously without user commands
3. Auto-start configurations required for all services

## File Organization (OD/UF Compliance)
- Follow Linux FHS (Filesystem Hierarchy Standard)
- Critical files must be properly organized:
  - Config files: ~/.config/claude-code/
  - Data files: ~/.local/share/claude-code/
  - Cache: ~/.cache/claude-code/
  - Global memory: ~/claude_global_memory/
- Never scatter files in random locations

## GitHub Workflow Preferences
- **NEVER commit directly to main branch** - Use feature branches only
- **Automated PR creation** preferred over manual git commands
- **Branch protection is mandatory** - Multiple safeguards must be active
- **Use autonomous agent** for routine commits and updates

## Documentation Standards
- **Only create docs when explicitly requested** - No proactive documentation
- **Update existing files** rather than creating new ones
- **Keep documentation factual** - Current state, not aspirational
- **Use structured formats** - Tables, lists, clear sections

## MCP Server Preferences
- **Test before declaring functional** - Actually verify servers work
- **Document all dependencies** - API keys, installation steps
- **Prefer enhanced versions** - Choose advanced over basic implementations
- **Automate server startup** - No manual intervention required

## Error Handling
- **Fail gracefully** - Provide clear error messages
- **Suggest alternatives** - When automation fails, offer simplest manual option
- **Log everything** - Maintain audit trail for debugging
- **Never ignore errors** - Address or escalate all issues

## Security Preferences
- **No hardcoded credentials** - Use environment variables or Doppler
- **Proper file permissions** - 600 for sensitive files
- **Validate all inputs** - Especially for file operations
- **Audit trail required** - Log all significant actions

## Communication Style
- **Be explicit about limitations** - When automation isn't possible
- **Provide status updates** - During long operations
- **Use clear language** - Avoid jargon unless necessary
- **Confirm understanding** - Verify requirements before acting

Last Updated: 2025-07-29
Status: ACTIVE - MUST FOLLOW