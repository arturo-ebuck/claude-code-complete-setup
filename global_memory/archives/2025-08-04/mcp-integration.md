# MCP (Model Context Protocol) Integration Guide

## Overview

MCP enables Claude to interact with external services and tools through a standardized protocol. This guide covers integration, configuration, and best practices for MCP servers.

## Core Concepts

### 1. MCP Architecture
- **MCP Servers**: Standalone services providing specific functionality
- **MCP Client**: Claude desktop app acting as client
- **Transport**: Communication layer (stdio, HTTP, etc.)
- **Resources**: Data exposed by servers
- **Tools**: Functions that servers provide

### 2. Server Types
- **Filesystem**: Local file operations
- **Database**: SQL, NoSQL interactions
- **API Wrappers**: External service integrations
- **Custom Tools**: Specialized functionality

## Configuration

### 1. Claude Desktop Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": ["/path/to/mcp-server-filesystem/dist/index.js"],
      "env": {
        "ALLOWED_DIRECTORIES": "/home/user/projects"
      }
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 2. Environment Variables
- **Doppler Integration**: Use for secure secret management
- **Direct Variables**: Set in server configuration
- **Path Variables**: Ensure proper PATH setup

## Available MCP Servers

### 1. Filesystem Server
**Purpose**: Enhanced file operations
**Features**:
- Advanced file search
- Bulk operations
- Permission management
- Watch functionality

**Configuration**:
```json
{
  "filesystem": {
    "command": "node",
    "args": ["./mcp-servers/filesystem/index.js"],
    "env": {
      "ALLOWED_DIRECTORIES": "/home/user/projects:/home/user/documents"
    }
  }
}
```

### 2. GitHub Server
**Purpose**: GitHub repository management
**Features**:
- Repository operations
- Issue management
- Pull request handling
- Workflow automation

**Configuration**:
```json
{
  "github": {
    "command": "npx",
    "args": ["@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_TOKEN": "${DOPPLER_GITHUB_TOKEN}"
    }
  }
}
```

### 3. Exa Server
**Purpose**: Advanced web search
**Features**:
- Semantic search
- Content extraction
- Result filtering
- Batch queries

**Configuration**:
```json
{
  "exa": {
    "command": "node",
    "args": ["./mcp-servers/exa/index.js"],
    "env": {
      "EXA_API_KEY": "${DOPPLER_EXA_API_KEY}"
    }
  }
}
```

### 4. Sequential Thinking Server
**Purpose**: Enhanced reasoning capabilities
**Features**:
- Step-by-step analysis
- Complex problem solving
- Decision trees
- Logic validation

**Configuration**:
```json
{
  "sequential-thinking": {
    "command": "node",
    "args": ["./mcp-servers/sequential-thinking/index.js"]
  }
}
```

### 5. Firecrawl Server
**Purpose**: Web scraping and crawling
**Features**:
- Page extraction
- Site crawling
- Content parsing
- Data structuring

**Configuration**:
```json
{
  "firecrawl": {
    "command": "python",
    "args": ["./mcp-servers/firecrawl/server.py"],
    "env": {
      "FIRECRAWL_API_KEY": "${DOPPLER_FIRECRAWL_API_KEY}"
    }
  }
}
```

## Installation Process

### 1. Server Setup
```bash
# Clone server repository
git clone <server-repo>
cd <server-name>

# Install dependencies
npm install  # or pip install -r requirements.txt

# Build if necessary
npm run build

# Test server
npm test
```

### 2. Configuration Update
1. Edit Claude desktop config
2. Add server configuration
3. Set environment variables
4. Restart Claude

### 3. Verification
```bash
# Check server status
./test-mcp-servers-status.sh

# Test specific server
node test-server.js <server-name>
```

## Best Practices

### 1. Security
- **API Keys**: Always use Doppler or environment variables
- **Permissions**: Limit server access appropriately
- **Validation**: Validate all inputs and outputs
- **Logging**: Maintain audit logs

### 2. Performance
- **Caching**: Implement appropriate caching
- **Rate Limiting**: Respect API limits
- **Timeout Handling**: Set reasonable timeouts
- **Resource Management**: Monitor resource usage

### 3. Error Handling
- **Graceful Failures**: Handle errors without crashing
- **Meaningful Messages**: Provide clear error descriptions
- **Retry Logic**: Implement smart retry mechanisms
- **Fallback Options**: Have backup strategies

### 4. Development
- **Testing**: Comprehensive test coverage
- **Documentation**: Clear usage documentation
- **Versioning**: Semantic versioning
- **Monitoring**: Health checks and metrics

## Creating Custom MCP Servers

### 1. Server Structure
```
mcp-server-custom/
├── package.json
├── src/
│   ├── index.ts
│   ├── handlers/
│   ├── tools/
│   └── resources/
├── tests/
└── README.md
```

### 2. Basic Implementation
```typescript
import { Server } from '@modelcontextprotocol/sdk';

const server = new Server({
  name: 'custom-server',
  version: '1.0.0',
});

// Define tools
server.setRequestHandler('tools/list', async () => ({
  tools: [{
    name: 'custom_tool',
    description: 'My custom tool',
    inputSchema: {
      type: 'object',
      properties: {
        input: { type: 'string' }
      }
    }
  }]
}));

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  // Implementation
});

// Start server
server.start();
```

### 3. Testing
```typescript
describe('Custom Server', () => {
  it('should list tools', async () => {
    const response = await server.handleRequest({
      method: 'tools/list'
    });
    expect(response.tools).toHaveLength(1);
  });
});
```

## Troubleshooting

### 1. Common Issues
- **Server Not Starting**: Check paths and permissions
- **Authentication Failures**: Verify API keys
- **Connection Errors**: Check firewall and ports
- **Timeout Issues**: Adjust timeout settings

### 2. Debugging
```bash
# Enable debug logging
export MCP_DEBUG=true

# Check server logs
tail -f ~/.claude/logs/mcp-*.log

# Test server directly
node server.js --test
```

### 3. Health Checks
```javascript
// Health check endpoint
server.setRequestHandler('health', async () => ({
  status: 'healthy',
  version: '1.0.0',
  uptime: process.uptime()
}));
```

## Integration Patterns

### 1. Chaining Operations
```
1. Use MCP server for data retrieval
2. Process with Claude's reasoning
3. Use another MCP server for output
4. Verify results
```

### 2. Fallback Strategies
```
Primary: Use specialized MCP server
Fallback 1: Use general-purpose server
Fallback 2: Use Claude's built-in tools
```

### 3. Parallel Operations
```
- Launch multiple MCP operations
- Gather results asynchronously
- Combine and process
- Return unified response
```

## Server Management

### 1. Monitoring
- **Status Checks**: Regular health monitoring
- **Performance Metrics**: Track response times
- **Error Rates**: Monitor failure patterns
- **Resource Usage**: CPU, memory, network

### 2. Maintenance
- **Updates**: Keep servers updated
- **Dependencies**: Update packages regularly
- **Security Patches**: Apply promptly
- **Configuration Reviews**: Periodic audits

### 3. Scaling
- **Load Balancing**: For high-traffic servers
- **Caching Layers**: Reduce redundant operations
- **Queue Management**: Handle burst traffic
- **Resource Limits**: Prevent overconsumption

## Future Considerations

### 1. Upcoming Features
- Enhanced protocol capabilities
- Better error handling
- Performance improvements
- New server types

### 2. Best Practice Evolution
- Standardized patterns
- Community contributions
- Security enhancements
- Tool ecosystems

## Last Updated
2025-07-29

## Status
ACTIVE - MCP INTEGRATION GUIDE