# Security Guidelines for Claude Code

## Core Security Principles

### 1. File Access Control
- **OD/UF Policy**: Strictly follow Open Directory and User Files policy
- **Path Validation**: Always validate file paths before operations
- **Absolute Paths**: Use absolute paths to avoid directory traversal attacks
- **Permission Checks**: Verify file permissions before modifications

### 2. Sensitive Information Handling
- **Never Store**: API keys, passwords, or tokens in plain text files
- **Use Doppler**: Leverage Doppler for secure secret management
- **Environment Variables**: Access secrets via environment variables only
- **Git Ignore**: Ensure .gitignore excludes all sensitive files

### 3. Command Execution Safety
- **Input Validation**: Sanitize all user inputs before command execution
- **Avoid Shell Injection**: Use parameterized commands, never string concatenation
- **Timeout Limits**: Apply reasonable timeouts to prevent hanging processes
- **Error Handling**: Catch and handle command failures gracefully

### 4. Network Security
- **HTTPS Only**: Always use HTTPS for API calls and web requests
- **Certificate Validation**: Never disable SSL certificate verification
- **API Rate Limits**: Implement rate limiting to prevent abuse
- **Authentication**: Use proper authentication headers for all API requests

### 5. Git Security
- **Branch Protection**: Enable branch protection for main/master branches
- **Pre-commit Hooks**: Use hooks to prevent accidental secret commits
- **Code Review**: Always review changes before merging
- **Signed Commits**: Enable GPG signing for commits when possible

### 6. MCP Server Security
- **Isolated Environments**: Run MCP servers in isolated environments
- **Limited Permissions**: Grant minimal required permissions
- **Audit Logs**: Maintain logs of all MCP server activities
- **Regular Updates**: Keep MCP servers and dependencies updated

### 7. Data Protection
- **Encryption at Rest**: Encrypt sensitive data stored locally
- **Secure Deletion**: Use secure deletion methods for sensitive files
- **Backup Security**: Ensure backups are encrypted and access-controlled
- **Data Minimization**: Only store necessary data

### 8. Access Control
- **Principle of Least Privilege**: Grant minimal required permissions
- **Regular Audits**: Review and revoke unnecessary access
- **Authentication**: Use strong authentication methods
- **Session Management**: Implement proper session timeouts

### 9. Logging and Monitoring
- **Security Events**: Log all security-relevant events
- **Anomaly Detection**: Monitor for unusual patterns
- **Log Protection**: Secure logs from tampering
- **Regular Reviews**: Periodically review security logs

### 10. Incident Response
- **Response Plan**: Have a clear incident response procedure
- **Immediate Actions**: Know what to do if security is compromised
- **Communication**: Clear channels for reporting security issues
- **Post-Incident**: Learn from incidents and update procedures

## Security Checklist

Before executing any operation:
- [ ] Validate all input parameters
- [ ] Check file/directory permissions
- [ ] Ensure no sensitive data is exposed
- [ ] Verify command safety
- [ ] Confirm operation is authorized
- [ ] Log the operation appropriately

## Emergency Procedures

If security breach suspected:
1. Stop all operations immediately
2. Revoke compromised credentials
3. Document the incident
4. Notify appropriate parties
5. Review and update security measures

## Last Updated
2025-07-29

## Status
ACTIVE - CRITICAL GUIDELINES