# MCP (Model Context Protocol) Setup Guide

## What is MCP?

MCP enables AI assistants (OpenCode, Cursor, Claude Desktop) to directly access tools like:
- **filesystem** - Read/write files
- **git** - Execute git commands
- **memory** - Remember context across sessions
- **github** - Access GitHub API (issues, PRs, releases)

## Quick Start

MCP is **optional**. The template works without it, but MCP significantly enhances AI capabilities.

**3 of 4 MCP servers work immediately:**
- ✅ filesystem (ready)
- ✅ git (ready)
- ✅ memory (ready)
- ⚠️ github (requires token setup)

---

## Prerequisites

### 1. Install Bun

**macOS/Linux:**
```bash
curl -fsSL https://bun.sh/install | bash
```

**Windows:**
```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

Verify: `bun --version`

### 2. Install uv

**macOS/Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows:**
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Verify: `uv --version`

---

## GitHub MCP Setup (Optional)

### Why do you need this?

**Without GitHub token:**
- AI can still use `gh` CLI (if you're authenticated)
- Uses your personal GitHub credentials
- Simpler setup

**With GitHub MCP token:**
- ✅ Better performance (persistent connection vs. subprocess calls)
- ✅ Fine-grained permissions (limit what AI can access)
- ✅ Cross-tool compatibility (works with Cursor, Claude Desktop, etc.)
- ✅ Isolated from your personal account

### When to skip GitHub MCP?

Skip if:
- You rarely ask AI to interact with GitHub
- `gh` CLI integration is sufficient
- You're just testing the template

### GitHub Token Permission Levels

Choose based on how much you trust AI with your repository:

#### 🟢 Level 1: Read-Only (Safest)

**Use when:** Testing, maximum security

**Token settings:**
- Go to: https://github.com/settings/personal-access-tokens/new
- Token name: `my-vibe-scaffolding-mcp`
- Expiration: `90 days`
- Repository access: `Only select repositories` → Select your repo
- Permissions → Repository permissions:
  - `Contents`: Read-only
  - `Issues`: Read-only
  - `Metadata`: Read-only (automatic)
  - `Pull requests`: Read-only

**AI can:** View code, issues, PRs  
**AI cannot:** Create/modify anything

---

#### 🟡 Level 2: Recommended (Balanced) ✨

**Use when:** Daily development, AI as collaborator

**Token settings:**
- Go to: https://github.com/settings/personal-access-tokens/new
- Token name: `my-vibe-scaffolding-mcp`
- Expiration: `90 days`
- Repository access: `Only select repositories` → Select your repo
- Permissions → Repository permissions:
  - `Contents`: **Read and write**
  - `Issues`: **Read and write**
  - `Metadata`: Read-only (automatic)
  - `Pull requests`: **Read and write**
  - `Workflows`: **Read and write**
  - `Administration`: **Read and write** (optional, for releases)

**AI can:** Create PRs, manage issues, trigger workflows, create releases  
**AI cannot:** Delete repo, modify settings, access other repositories

**Safety net:**
- Use branch protection rules (require PR reviews)
- AI-created PRs still need your approval before merging
- All actions are reversible

---

#### 🔴 Level 3: Full Access (Testing Only)

**Use when:** Experimental repo, advanced automation

⚠️ **Not recommended for production repos**

Adds to Level 2:
- `Webhooks`: Read and write
- `Environments`: Read and write
- `Secrets`: Read and write ⚠️

---

## Step-by-Step Setup

### 1. Create GitHub Token

1. Go to: https://github.com/settings/personal-access-tokens/new
2. Fill in:
   - **Token name:** `my-vibe-scaffolding-mcp`
   - **Expiration:** `90 days` (recommended)
   - **Repository access:** `Only select repositories` → Select your repo
   - **Permissions:** Choose Level 2 (Recommended) settings above
3. Click **Generate token**
4. ⚠️ **Copy the token immediately** (format: `github_pat_...`)

### 2. Add Token to .env

```bash
# In your project directory
cp .env.example .env

# Edit .env and replace:
GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here

# With your actual token:
GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_11AAAA...
```

**Security check:**
```bash
# Verify .env is gitignored
grep "^\.env$" .gitignore
# Should output: .env
```

### 3. Test MCP Setup

```bash
./.template/scripts/test-mcp-setup.sh
```

This verifies:
- ✅ Bun and uv installed
- ✅ `opencode.json` syntax valid
- ✅ GitHub token configured
- ✅ `.env` properly gitignored

### 4. Restart Your AI Tool

**VSCode (OpenCode extension):**
- `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows)
- Type: "Reload Window"
- Press Enter

**Cursor / Claude Desktop:**
- Restart the application

---

## Verification

After restart, test GitHub MCP:

```bash
# Ask AI in chat:
"List the open issues in this repository using the GitHub MCP server"

# If working, AI will use MCP instead of `gh` CLI
```

---

## Troubleshooting

### Token not working?

```bash
# Test token manually
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

Expected output: Your GitHub username

### MCP servers not loading?

1. Check `opencode.json` syntax:
   ```bash
   jq empty opencode.json
   ```

2. Verify Bun/uv paths:
   ```bash
   which bunx  # Should output path
   which uv    # Should output path
   ```

3. Check OpenCode logs (VSCode):
   - `Cmd+Shift+P` → "OpenCode: Show Logs"

### .env not loading?

Ensure:
- File named exactly `.env` (not `.env.txt`)
- Located in project root (same level as `opencode.json`)
- Syntax: `KEY=value` (no spaces around `=`)

---

## Security Best Practices

### ✅ DO

- Use Fine-grained tokens (not Classic)
- Limit to specific repositories
- Set expiration (90 days recommended)
- Use Level 2 permissions for daily work
- Enable branch protection rules
- Rotate tokens regularly

### ❌ DON'T

- Never commit `.env` to git
- Never use "All repositories" access
- Never share tokens in chat/email
- Never skip expiration (max 1 year)
- Never give `delete_repo` permission
- Never use Classic tokens if avoidable

---

## Token Rotation

Every 90 days:

1. Generate new token (same settings)
2. Update `.env` with new token
3. Revoke old token on GitHub
4. Restart AI tool

---

## FAQ

**Q: Can I use multiple repositories with one token?**  
A: Yes, select multiple repos in "Repository access" when creating the token.

**Q: What if token expires?**  
A: AI will lose GitHub MCP access. Just create a new token and update `.env`.

**Q: Is my token safe?**  
A: Yes, if:
- `.env` is gitignored (check: `git status` should not show `.env`)
- You use Fine-grained tokens limited to specific repos
- You set expiration dates

**Q: Can I skip GitHub MCP entirely?**  
A: Absolutely! AI can still use `gh` CLI. GitHub MCP is a performance/security enhancement, not required.

**Q: What's the difference from `gh` CLI?**  
A: 
- `gh` CLI: Uses your personal credentials, slower (subprocess calls)
- GitHub MCP: Dedicated token, faster (persistent connection), cross-tool compatible

---

## Additional Resources

- MCP Documentation: https://modelcontextprotocol.io/
- GitHub Tokens Guide: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
- OpenCode MCP Support: https://github.com/OpenCodeProject/opencode
