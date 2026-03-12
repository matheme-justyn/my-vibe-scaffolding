# Service Detection Protocol

**Quick Start**: AI agents automatically check service availability before making API calls.

## What is Service Detection?

When AI agents work on your project, they might try to call external services (web search, GitHub API, etc.). If those services aren't configured, you get cryptic errors.

**Service Detection solves this** by:
1. Checking service availability BEFORE calling
2. Using alternatives automatically
3. Providing clear error messages

## How It Works

### 1. Configuration (config.toml)

```toml
[services]
unsupported = ["google-search", "google_search"]  # Services that won't work

[services.alternatives]
google-search = ["websearch_web_search_exa", "webfetch"]  # Use these instead
```

### 2. Agent Protocol

AI agents follow this protocol:

1. **Check** `config.toml` before calling any external service
2. **Skip** services in `unsupported` list
3. **Use** alternatives from `[services.alternatives]`
4. **Inform** user about substitution

### 3. Example

**Without Service Detection:**
```
User: "Search the web for React hooks best practices"
Agent: [Attempts google-search]
Result: ❌ 403 Forbidden - Gemini for Google Cloud API has not been used...
```

**With Service Detection:**
```
User: "Search the web for React hooks best practices"
Agent: [Checks config.toml → google-search in unsupported list]
Agent: "Using websearch_web_search_exa as alternative to google-search"
Agent: [Executes successfully]
Result: ✅ Search results returned
```

## Configuration Guide

### Default Configuration

The template comes with sensible defaults in `config.toml.example`:

```toml
[services]
unsupported = ["google-search"]  # Known unavailable services

[services.alternatives]
google-search = ["websearch_web_search_exa", "webfetch"]

[services.fallback]
mode = "suggest"        # "suggest" | "auto" | "fail"
log_attempts = true     # Log all service calls
show_reason = true      # Show why alternative was chosen
```

### Customization

1. Copy example config:
   ```bash
   cp config.toml.example config.toml
   ```

2. Add your unavailable services:
   ```toml
   [services]
   unsupported = [
       "google-search", 
       "github_api",      # If you don't have GitHub token
       "docker"           # If Docker isn't installed
   ]
   ```

3. Define alternatives:
   ```toml
   [services.alternatives]
   google-search = ["websearch_web_search_exa", "webfetch"]
   github_api = ["git_cli"]  # Use git CLI instead of API
   docker = ["podman"]       # Use Podman as Docker alternative
   ```

## Service Capability Matrix

| Functionality | Unavailable Service | Available Alternative | When to Use |
|---------------|---------------------|----------------------|-------------|
| Web Search | `google-search` | `websearch_web_search_exa` | LLM-optimized search results |
| URL Fetch | — | `webfetch` | Direct URL content retrieval |
| Code Search | — | `grep_app_searchGitHub` | Find code examples on GitHub |
| Documentation | — | `context7_query-docs` | Query library documentation |

## Agent Error Messages

When a service is unavailable, agents provide structured errors:

```
❌ Service 'google-search' is not available in this configuration.

Reason: Listed in config.toml [services.unsupported]

✅ Available alternatives:
  1. websearch_web_search_exa - LLM-optimized web search
  2. webfetch - Direct URL fetching

Recommended: websearch_web_search_exa
Using: websearch_web_search_exa

[Continues execution with alternative]
```

## Fallback Modes

Control how agents handle unavailable services:

### `mode = "suggest"` (Default)
- Agent lists alternatives
- Recommends best option
- Uses it automatically
- User can see what happened

### `mode = "auto"`
- Agent silently uses alternative
- Faster but less transparent

### `mode = "fail"`
- Agent stops execution
- Returns error message
- User must fix configuration

## Troubleshooting

### Service Still Fails After Configuration

1. **Check spelling**: Service names are case-sensitive
   ```toml
   # ❌ Wrong
   unsupported = ["Google-Search"]
   
   # ✅ Correct
   unsupported = ["google-search"]
   ```

2. **Check alternative availability**: Make sure alternative tools exist
   ```bash
   # Test if alternative tool is available
   opencode --list-tools | grep websearch_web_search_exa
   ```

3. **Check logs**: Enable logging to see detection in action
   ```toml
   [services.fallback]
   log_attempts = true
   show_reason = true
   ```

### Adding New Service Detection

1. Identify the failing service call
2. Add to `unsupported` list
3. Find available alternatives
4. Test with a simple prompt

Example:
```bash
# 1. Identify failing service (check error message)
# Error: "docker: command not found"

# 2. Add to config.toml
[services]
unsupported = ["docker"]

# 3. Define alternative
[services.alternatives]
docker = ["podman", "nerdctl"]

# 4. Test
# Ask agent: "Build a Docker image"
# Agent should use Podman automatically
```

## Implementation Details

For AI agent developers:

- **Configuration loading**: Agents read `config.toml` at session start
- **Cache duration**: Config is cached per session (no re-reads)
- **Override priority**: Project config > User config > Default config
- **Error handling**: Graceful degradation, never crash on detection failure

## Related Documentation

- [`.agents/service-detection.md`](../../.agents/service-detection.md) - Full technical specification for AI agents
- [`docs/adr/0008-opencode-config-claude-code-reference.md`](./adr/0008-reference-claude-code-architecture.md) - Architecture decision record
- [`AGENTS.md`](../../AGENTS.md) - Service Detection Protocol section

## FAQs

**Q: Do I need to configure this?**  
A: No. The template has sensible defaults. Only customize if you encounter service errors.

**Q: How do I know which services to mark as unsupported?**  
A: Wait for agent errors, then add the failing service to the list.

**Q: Can I disable service detection?**  
A: Not recommended. Service detection prevents confusing errors. If needed, set `mode = "fail"` to require manual intervention.

**Q: Does this work with all AI tools (Cursor, Claude, Copilot)?**  
A: Currently optimized for OpenCode. Other tools may need manual adaptation.

---

**Version**: 1.0.0  
**Last Updated**: 2026-03-12  
**Maintainer**: my-vibe-scaffolding template
