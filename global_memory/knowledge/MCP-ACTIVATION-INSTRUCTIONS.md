# MCP Activation Instructions

## Tools Requiring Manual Commands

### 1. SuperClaude - Slash Commands Required
**Status**: Installed and ready
**Activation**: Use `/sc:` prefix

**Commands You Must Type**:
- `/sc:implement <feature>` - Build new features
- `/sc:analyze <code>` - Deep code analysis
- `/sc:troubleshoot <issue>` - Debug problems
- `/sc:design <system>` - Architecture design
- `/sc:improve <code>` - Optimize code
- `/sc:test` - Create tests
- `/sc:document` - Generate docs
- `/sc:build` - Compile/package
- `/sc:cleanup` - Code cleanup
- `/sc:explain` - Explain code
- `/sc:git` - Git operations
- `/sc:estimate` - Time estimates
- `/sc:task` - Task management
- `/sc:index` - Index codebase
- `/sc:load` - Load context
- `/sc:spawn` - Spawn agents

**Personas activate automatically based on context**

### 2. Graphiti - Not Yet Installed
**Status**: ⚠️ Requires installation
**Activation**: Would need manual tool calls

**To Install**:
```bash
# Clone repository
cd /home/jb_remus/claude-code-desktop02-setup/mcp-servers/
git clone https://github.com/Paul-Allen-AI/graphiti.git
cd graphiti && uv sync

# Start Neo4j
docker run -d --name graphiti-neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  neo4j:latest

# Add to MCP config
# Then use tools: add_episode, search, get_nodes, etc.
```

### 3. Sequential-Thinking - Mostly Automatic
**Status**: ✅ Active and working
**Activation**: I use automatically for complex problems

**Manual Override Commands** (rarely needed):
- Force clear: Ask me to "clear sequential thinking history"
- Force summary: Ask me to "generate thinking summary"

## Fully Automatic MCPs (No Commands Needed)

These activate based on context:
- **filesystem** - File operations
- **git** - Version control
- **github** - GitHub operations
- **exa** - Neural search
- **firecrawl** - Web scraping
- **perplexity** - AI search
- **docker** - Container management
- All others in the list

## Summary

**Only 2 require your commands**:
1. **SuperClaude**: Use `/sc:` commands
2. **Graphiti**: Not installed yet

Everything else activates automatically based on what you're asking me to do!