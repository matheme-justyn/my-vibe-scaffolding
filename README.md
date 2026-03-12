<div align="center">

<img src="./.template/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-1.15.0-blue.svg)](./.template/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

English | [繁體中文](./README.zh-TW.md)

</div>

---

## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Based on psychologist Lev Vygotsky's scaffolding theory - provides structure when you need it, remove it when you don't.

<div align="center">
<img src="./.template/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.template/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
</div>
### Core Features

- 🤖 **AI Agent Integration** - `AGENTS.md` + Skills system for OpenCode/Cursor/Claude
- 📦 **Version Management** - Pre-push hooks enforce version updates
- 🌐 **Multi-language** - BCP 47 i18n for documentation
- 🛠️ **Smart Setup** - First-time setup handled automatically by AI agent

---

## 🚀 Installation

1. Click **"Use this template"** on GitHub to create your repository
2. Clone your new repository
3. Start using — the template is ready out of the box

**Note**: First-time setup will be handled automatically by AI agent when needed

---

## ⚙️ Configuration - AI Skills

### What are Skills?

**Skills** = Reusable AI workflows (like functions for AI agents)

Example: `test-driven-development`, `systematic-debugging`, `brainstorming`

### Where Your Skills Are

You already have **14 skills** available:
- 📍 `~/.config/opencode/skills/superpowers/` - User-level skills
- 📍 `.agents/skills/` - Project-specific skills (create if needed)

### How to Use Skills

**Option 1: Auto-trigger via AGENTS.md** (Recommended)

Skills load automatically based on task type. See `AGENTS.md` for trigger keywords.

**Option 2: Manual Load**

```
@use brainstorming
User: "Design an authentication system"
```

**Option 3: Use Bundles**

```
@use bundle:backend-dev
```

### Available Skills

- `brainstorming` - Feature ideation
- `test-driven-development` - TDD workflow
- `systematic-debugging` - Bug diagnosis
- `requesting-code-review` - Code review
- `using-git-worktrees` - Git workflow
- ...and 9 more

📖 **Full guide:** [`.template/docs/SKILLS_USAGE_GUIDE.md`](./.template/docs/SKILLS_USAGE_GUIDE.md)

---

## 🎯 Tech Stack

Why these technologies?

| Technology | Why | Problem Solved |
|------------|-----|----------------|
| **OpenCode** (Open-source AI) | 75+ models, CLI-first | Avoid vendor lock-in |
| **AGENTS.md Standard** | Cross-tool compatible | AI understands project conventions |
| **Skills System** | Reusable workflows | Encode best practices |
| **Bundles & Workflows** | Role-based collections | Quick context loading |

We use [superpowers](https://github.com/ohmyopencode/superpowers) - community-driven AI workflows.

---

## 🗂️ Why `.template/` Directory?

**Question**: Why `.template/` instead of `template/` or `scaffolding/`?

**Answer**: Intentional design choice based on:

1. **Hidden by default** - Leading dot indicates "system/framework" files
2. **Version control friendly** - Git shows `.template/` changes separately from project code
3. **AI agent clarity** - Agents distinguish "template structure" vs "project files"
4. **Industry precedent** - Follows `.github/`, `.vscode/`, `.husky/` pattern

**Alternative considered**: `template/` (rejected - too visible, confuses with project templates)

---

## 🛡️ Service Detection

**Problem**: AI agents attempt to call unavailable services (e.g., `google-search` when API not configured)

**Solution**: Declarative service availability in `config.toml`:

```toml
[services]
unsupported = ["google-search", "google_search"]

[services.alternatives]
google-search = ["websearch_web_search_exa", "webfetch"]
```

**AI Agent Protocol**:
1. Check `config.toml` before calling ANY external service
2. If service in `unsupported` list → use alternative
3. Inform user of substitution

📖 **Full protocol**: [`.agents/service-detection.md`](./.agents/service-detection.md)

---


## 🤖 Advanced AI Agent Features

**NEW in v1.15.0**: Complete five-layer AI architecture from hackathon-winning [everything-claude-code](https://github.com/affaan-m/everything-claude-code).

### Layer 1: Specialized Agents (5)

AI agents for task delegation and specialized workflows:

| Agent | Use Case | Example |
|-------|----------|---------|
| **planner** | Complex feature planning | "Plan user authentication system" |
| **architect** | Architecture decisions | "Choose database: PostgreSQL vs MongoDB" |
| **tdd-guide** | Test-driven development | "Implement checkout with TDD" |
| **code-reviewer** | Quality & security review | "Review auth.ts for issues" |
| **security-reviewer** | Vulnerability scanning | "Check password reset security" |

📖 **Full guide**: [`.agents/agents/README.md`](./.agents/agents/README.md)

### Layer 2: Core Skills (15)

Reusable expertise modules organized by domain:

**Universal (5)**: api-design, security-review, tdd-workflow, coding-standards, verification-loop  
**Backend (3)**: backend-patterns, database-optimization, error-handling  
**Frontend (3)**: frontend-patterns, react-hooks, component-design  
**Testing (2)**: e2e-testing, unit-testing  
**Other (2)**: content-engine, market-research

**Usage**:
```typescript
// Auto-loads based on keywords
User: "Design REST API" → api-design, security-review, backend-patterns

// Manual load
@use api-design
@use security-review
```

📖 **Full guide**: [`.agents/skills/README.md`](./.agents/skills/README.md)

### Layer 3: Commands (10)

Task-specific workflows for common operations:

| Command | Description | When to Use |
|---------|-------------|-------------|
| **plan** | Create implementation plan | Starting complex features |
| **code-review** | Review code quality | Before commits/PRs |
| **test-all** | Run all tests + coverage | Pre-commit, CI/CD |
| **security-scan** | Vulnerability audit | Pre-deployment |
| **refactor** | Systematic refactoring | Improving code quality |
| **document** | Generate docs | API docs, README |

**Common Workflows**:
- **Feature Dev**: plan → checkpoint → [code] → test-all → code-review → security-scan
- **Bug Fix**: checkpoint → analyze → [fix] → test-all → code-review
- **Refactor**: analyze → checkpoint → test-all → refactor → test-all

📖 **Full guide**: [`.agents/commands/README.md`](./.agents/commands/README.md)

### Layer 4: Rules (60)

Behavioral constraints across 4 categories:

- **Git Rules (11)**: Never commit secrets, meaningful commits, safe force-push
- **Testing Rules (16)**: TDD workflow, 80%+ coverage, no flaky tests
- **Security Rules (13)**: Input validation, parameterized queries, httpOnly cookies
- **Code Style Rules (20)**: Naming conventions, function size, no magic numbers

**Severity Levels**: 🔴 CRITICAL (blocks) | 🟠 HIGH (fix before merge) | 🟡 MEDIUM | 🟢 LOW

📖 **Full guide**: [`.agents/rules/README.md`](./.agents/rules/README.md)

### Layer 5: AgentShield

Security framework preventing AI configuration vulnerabilities:

- **File Operations**: Confirm before deleting/overwriting
- **Command Execution**: Block destructive commands without confirmation
- **External Services**: Require permission for API calls with credentials
- **Code Modification**: Flag auth/payment code for human review
- **Data Access**: Protect sensitive files (.env, SSH keys)

📖 **Full guide**: [`.agents/agentshield/README.md`](./.agents/agentshield/README.md)

---

## 🏗️ Architecture

This template adapts **Claude Code's five-layer architecture** (2025 hackathon winner):

| Layer | Claude Code | This Template | Status |
|-------|-------------|---------------|--------|
| **1. Agents** | Delegation system | Task delegation in `AGENTS.md` | ✅ Complete |
| **2. Skills** | Prompt modules | `.agents/skills/`, superpowers | ✅ Complete |
| **3. Commands** | Task mappings | Commands block in `AGENTS.md` | ✅ Complete |
| **4. Hooks** | Git automation | `.template/scripts/install-hooks.sh` | ✅ Complete |
| **5. Rules** | Guardrails | Service detection, conventions | ✅ Complete |

🔗 **Design decisions**: [`docs/adr/0009-reference-claude-code-architecture.md`](./docs/adr/0009-reference-claude-code-architecture.md)

---

## 📄 License

MIT License - See [LICENSE](./LICENSE)

---

<div align="center">

**Based on Vygotsky's Scaffolding Theory | Powered by AI | For Developers**

[Documentation](./.template/docs/) | [Changelog](./.template/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
