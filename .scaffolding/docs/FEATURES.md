# My Vibe Scaffolding - Technical Features

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](../../VERSION)

> **Comprehensive feature documentation for AI-driven project scaffolding template**

---

## Table of Contents

- [What's New in v2.0.0](#whats-new-in-v20)
  - [Module System](#-module-system)
  - [Academic Project Support](#-academic-project-support)
  - [Multi-Language PR Templates](#-multi-language-pr-templates)
  - [Enhanced Infrastructure](#️-enhanced-infrastructure)
  - [Core Module Documentation](#-core-module-documentation)
  - [Quick Start with v2.0.0](#-quick-start-with-v20)
- [Configuration - AI Skills](#️-configuration---ai-skills)
- [Tech Stack](#-tech-stack)
- [Why `.scaffolding/` Directory](#️-why-scaffolding-directory)
- [Service Detection](#️-service-detection)
- [Architecture](#️-architecture)

---

## 🎉 What's New in v2.0.0

Major upgrade with Module System, Academic Support, and enhanced AI workflows:

### 📚 Module System

Config-driven conditional documentation loading:

- **31 modules** organized by domain (frontend/backend/fullstack/academic)
- **6 core modules** always loaded: STYLE_GUIDE, GIT_WORKFLOW, ACADEMIC_WRITING, CITATION_MANAGEMENT, CONTEXT_FILE, AGENTS
- **25 conditional modules** loaded based on `config.toml` project type
- **Terminology system**: 183 standardized terms across software/academic domains
- **Hierarchical loading**: Universal → Domain-specific → Custom overrides

**How it works:**

1. AI agent reads `config.toml` to understand project type
2. Detects task keywords to determine needed modules
3. Loads ONLY relevant modules for current task
4. Token usage reduced by 70%+ compared to full-inline approach

**Example configuration:**

```toml
[project]
type = "fullstack"  # frontend | backend | fullstack | cli | library | academic
features = ["api", "database", "auth", "i18n"]
quality = ["performance", "accessibility"]

[modules]
always_enabled = ["STYLE_GUIDE", "TERMINOLOGY", "GIT_WORKFLOW"]
manual_enabled = []
manual_disabled = []
```

**Module Categories:**

| Category | Count | Modules |
|----------|-------|---------|
| **Core** | 5 | STYLE_GUIDE, TERMINOLOGY, GIT_WORKFLOW, TESTING_STRATEGY, SECURITY_CHECKLIST |
| **Software Dev** | 6 | FRONTEND_PATTERNS, BACKEND_PATTERNS, API_DESIGN, DATABASE_CONVENTIONS, CLI_DESIGN, LIBRARY_DESIGN |
| **Academic** | 6 | ACADEMIC_WRITING, CITATION_MANAGEMENT, TRANSLATION_GUIDE, LITERATURE_REVIEW, RESEARCH_ORGANIZATION, DOCUMENT_STRUCTURE |
| **Feature** | 4 | I18N_GUIDE, AUTH_IMPLEMENTATION, REALTIME_PATTERNS, FILE_HANDLING |
| **Quality** | 4 | PERFORMANCE_OPTIMIZATION, TROUBLESHOOTING, PRODUCTION_READINESS, ACCESSIBILITY |
| **Collaboration** | 4 | README_STRUCTURE, ADR_TEMPLATE, RELEASE_PROCESS, ONBOARDING_GUIDE |
| **Scaffolding** | 2 | SCAFFOLDING_DEV_GUIDE, MODE_GUIDE |

📖 **Full documentation**: [ADR 0012](../adr/0012-module-system-and-conditional-loading.md)

### 🎓 Academic Project Support

First-class support for research and academic writing:

- **Citation styles**: APA, MLA, Chicago, IEEE, ACM
- **Field-specific terminology**: Computer Science, Engineering, Social Science, Humanities
- **Academic writing standards**: Research methodology, literature review, thesis structure
- **ACADEMIC_WRITING.md** (777 lines): Complete academic writing guide
- **CITATION_MANAGEMENT.md** (741 lines): Citation and reference management

**Configuration example:**

```toml
[project]
type = "academic"

[academic]
citation_style = "APA"
field = "computer_science"
```

**Terminology Loading:**

```
type = "academic":
  → terminology.md (universal terms)
  → academic/common.md (research, writing, ethics)
  → academic/computer-science.md (AI/ML, algorithms, HCI)
```

### 🌐 Multi-Language PR Templates

Smart pull request templates with language detection:

- **4 languages**: English, Traditional Chinese, Simplified Chinese, Japanese
- **Auto-detection**: Uses `config.toml` primary language setting
- **Custom instructions**: Language-specific contribution guidelines
- **Script**: `.scaffolding/scripts/generate-pr-template.sh`

**Usage:**

```bash
# Auto-detects language from config.toml
./.scaffolding/scripts/generate-pr-template.sh

# Generates .github/pull_request_template.md
```

**Template structure:**

- PR title format (Angular style)
- Description guidelines
- Checklist (code quality, tests, documentation)
- Language-specific contribution notes

### 🛠️ Enhanced Infrastructure

New tools for project setup and configuration:

- **configure-project-type.sh** (377 lines): Interactive project type selector
- **ADR 0012** (655 lines): Complete Module System architecture documentation
- **MIGRATION_GUIDE.md** (245 lines): Upgrade guide from 1.x to 2.0.0
- **Module Loading Protocol** in AGENTS.md: AI agent conditional loading guide

**Key scripts:**

| Script | Purpose | Usage |
|--------|---------|-------|
| `configure-project-type.sh` | Set project type interactively | `./.scaffolding/scripts/configure-project-type.sh` |
| `generate-pr-template.sh` | Generate PR template (multi-language) | `./.scaffolding/scripts/generate-pr-template.sh` |
| `init-project.sh` | Initialize/update project | `./.scaffolding/scripts/init-project.sh` |
| `bump-version.sh` | Version management | `./.scaffolding/scripts/bump-version.sh [patch\|minor\|major]` |

### 📖 Core Module Documentation

4 high-priority modules complete (26 low-priority modules planned for 2.1.x):

- **STYLE_GUIDE.md** (838 lines): Universal code style guide
- **GIT_WORKFLOW.md** (855 lines): Git workflow, commits, PR standards
- **ACADEMIC_WRITING.md** (777 lines): Academic writing guidelines
- **CITATION_MANAGEMENT.md** (741 lines): Citation and reference management

**Current Status** (v2.0.0):

| Status | Modules | Note |
|--------|---------|------|
| ✅ **Complete** | 4 core modules | STYLE_GUIDE, GIT_WORKFLOW, ACADEMIC_WRITING, CITATION_MANAGEMENT |
| ✅ **Complete** | TERMINOLOGY (7 files) | Fully implemented terminology system |
| ⏸️ **Planned** | 26 conditional modules | Will be created in 2.1.x |

### 🚀 Quick Start with v2.0.0

```bash
# 1. Set up project type (interactive)
./.scaffolding/scripts/configure-project-type.sh

# 2. Configure your preferences in config.toml
# For academic projects, set:
#   [academic]
#   citation_style = "apa"
#   field = "computer_science"

# 3. Generate PR template (auto-detects language)
./.scaffolding/scripts/generate-pr-template.sh

# 4. Start coding - AI agent will load relevant modules automatically
```

**Upgrading from 1.x?** See [MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md) for detailed instructions.

---

## ⚙️ Configuration - AI Skills

### What are Skills?

**Skills** = Reusable AI workflows (like functions for AI agents)

Example: `test-driven-development`, `systematic-debugging`, `brainstorming`

**Key concept:**
- 📦 **Portable**: Work across OpenCode, Cursor, Windsurf, Claude
- 🔄 **Reusable**: Use in multiple projects
- 🎯 **Focused**: One skill, one job
- 📝 **Self-documenting**: Frontmatter describes purpose and usage

### Where Your Skills Are

You already have **14 skills** available:
- 📍 `~/.config/opencode/skills/superpowers/` - User-level skills
- 📍 `.agents/skills/` - Project-specific skills (create if needed)

**Skill Discovery Paths** (priority order):

```
1. .agents/skills/                      # Project-specific (highest priority)
2. .scaffolding/agents/skills/          # Template-provided
3. ~/.config/opencode/skills/           # User-installed (superpowers)
```

**Available Skills:**

**User Skills** (`superpowers/`):
- `brainstorming` - Feature ideation and planning
- `test-driven-development` - TDD workflow
- `systematic-debugging` - Systematic bug diagnosis
- `using-git-worktrees` - Isolated feature development
- `executing-plans` - Execute implementation plans
- `finishing-a-development-branch` - Complete development work
- ... (13 total skills)

**Template Skills** (`.scaffolding/agents/skills/`):
- Backend: `backend-patterns`, `database-optimization`, `error-handling`
- Frontend: `frontend-patterns`, `react-hooks`, `component-design`
- Universal: `api-design`, `security-review`
- Testing: `e2e-testing`, `unit-testing`

### How to Use Skills

**Option 1: Auto-trigger via AGENTS.md** (Recommended)

Skills load automatically based on task type. See `AGENTS.md` for trigger keywords.

Example: User says "新增登入功能" → auto-loads `brainstorming` + `test-driven-development`

**Option 2: Manual Load**

```
@use brainstorming
User: "Design an authentication system"
```

**Option 3: Use Bundles**

```
@use bundle:backend-dev
User: "Create a REST API for blog posts"
```

**Option 4: Execute Workflows**

```
@workflow feature-development
User: "Add user profile editing"
```

### Available Bundles

**Bundles** (`.agents/bundles.yaml`) - Role-based skill collections:

- `backend-dev` - API design, database, testing, security
- `frontend-dev` - Component design, state management, a11y
- `devops-specialist` - Infrastructure, deployment, monitoring
- `security-engineer` - Security auditing and hardening
- `project-start` - Brainstorming, architecture, setup
- `feature-development` - Building new features
- `production-ready` - Production deployment preparation
- `debugging-master` - Troubleshooting and fixing issues

### Creating New Skills

1. **Copy template:**
   ```bash
   cp -r .scaffolding/docs/examples/skills/template-skill .scaffolding/agents/skills/my-skill
   ```

2. **Edit SKILL.md:**
   - Update frontmatter (name, version, description, tags)
   - Define "When to Use" triggers
   - Write step-by-step "Instructions"
   - Add "Examples" and "Anti-Patterns"

3. **Test:**
   ```
   @use my-skill
   User: "Test my skill"
   ```

📖 **Full guide:** [SKILL_FORMAT_GUIDE.md](./SKILL_FORMAT_GUIDE.md)

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

### Why OpenCode?

**Problems with commercial AI tools:**
- 🔒 Vendor lock-in (Claude, GitHub Copilot)
- 💰 Expensive ($20-30/month per user)
- 🚫 Limited model choices
- 📊 Usage restrictions

**OpenCode advantages:**
- ✅ 75+ models (OpenAI, Anthropic, Google, local LLMs)
- ✅ CLI-first (scriptable, automatable)
- ✅ Open-source (MIT license)
- ✅ Self-hosted option

### Why AGENTS.md?

**Problem:** Each AI tool has different conventions (Cursor rules, Claude projects, GitHub Copilot settings)

**Solution:** AGENTS.md as universal standard

**Benefits:**
- 📝 Single source of truth for project conventions
- 🔄 Cross-tool compatible (OpenCode, Cursor, Windsurf, Claude)
- 🤖 AI agents read and follow automatically
- 📖 Human-readable documentation

**Structure:**

```markdown
AGENTS.md
├── Project Overview (goals, context)
├── Project Setup (installation, configuration)
├── Tech Stack (technologies, rationale)
├── Commands (development, testing, deployment)
├── Coding Conventions (style, patterns, guardrails)
├── Commit Message Format (conventional commits)
├── Pull Request Guidelines (title format, content)
└── AI Agent Protocols (communication, module loading, service detection)
```

### Why Skills System?

**Problem:** Repeating same instructions to AI in every session

**Solution:** Encapsulate workflows as reusable skills

**Benefits:**
- ♻️ Reusable across projects
- 📦 Portable across AI tools
- 🎯 Focused (one skill, one job)
- 📖 Self-documenting

**Comparison:**

| Approach | Reusability | Portability | Maintainability |
|----------|-------------|-------------|-----------------|
| **Ad-hoc prompts** | ❌ None | ❌ None | ❌ Hard to maintain |
| **Project-specific instructions** | ⚠️ Project only | ❌ Tool-locked | ⚠️ Scattered |
| **Skills System** | ✅ Cross-project | ✅ Cross-tool | ✅ Centralized |

---

## 🗂️ Why `.scaffolding/` Directory?

**Question**: Why `.scaffolding/` instead of `template/` or `scaffolding/`?

**Answer**: Intentional design choice based on:

1. **Hidden by default** - Leading dot indicates "system/framework" files
2. **Version control friendly** - Git shows `.scaffolding/` changes separately from project code
3. **AI agent clarity** - Agents distinguish "template structure" vs "project files"
4. **Industry precedent** - Follows `.github/`, `.vscode/`, `.husky/` pattern

**Alternative considered**: `template/` (rejected - too visible, confuses with project templates)

### Directory Structure

```
my-vibe-scaffolding/
├── .scaffolding/              # Template framework (hidden)
│   ├── docs/                  # Framework documentation
│   ├── scripts/               # Setup and utility scripts
│   ├── agents/                # AI agent configurations
│   │   ├── skills/            # Template-provided skills
│   │   ├── commands/          # Task-specific workflows
│   │   └── agents/            # Specialized agents
│   ├── i18n/                  # Internationalization
│   ├── VERSION                # Template version
│   └── CHANGELOG.md           # Template changes
├── .agents/                   # Project-specific AI config
│   └── skills/                # Custom skills (override template)
├── docs/                      # Project documentation
│   └── adr/                   # Architecture decisions
├── scripts/                   # Project scripts
├── config.toml                # Project configuration
├── AGENTS.md                  # AI agent instructions
└── README.md                  # Project README (auto-generated)
```

### Working Modes

**Scaffolding Mode** (`mode = "scaffolding"`):
- Developing this scaffolding itself
- ADRs go to `.scaffolding/docs/adr/`
- Scripts go to `.scaffolding/scripts/`
- CHANGELOG updates `.scaffolding/CHANGELOG.md`

**Project Mode** (`mode = "project"`):
- Using this scaffolding for your project
- ADRs go to `docs/adr/`
- Scripts go to `scripts/`
- CHANGELOG updates root `CHANGELOG.md`
- `.scaffolding/` contains reference examples only

**To change mode:** Edit `config.toml` and set `[project] mode = "scaffolding"` or `"project"`

---

## 🛡️ Service Detection

**Problem**: AI agents attempt to call unavailable services (e.g., `google-search` when API not configured)

**Solution**: Declarative service availability in `config.toml`:

```toml
[services]
unsupported = ["google-search", "google_search"]

[services.capabilities]
web_search = ["websearch_web_search_exa", "webfetch"]
code_search = ["grep_app_searchGitHub"]
documentation = ["context7_query-docs", "context7_resolve-library-id"]

[services.fallback]
mode = "suggest"  # "suggest" | "auto" | "fail"
log_attempts = true
show_reason = true
```

**AI Agent Protocol**:
1. Check `config.toml` before calling ANY external service
2. If service in `unsupported` list → look up alternatives in `[services.capabilities]`
3. Use alternative tool and inform user of substitution
4. Provide clear reasoning for why alternative was chosen

**Service Capability Matrix:**

| Functionality | Unsupported Services | Available Alternatives | Recommended |
|---------------|----------------------|------------------------|-------------|
| **Web Search** | `google-search`, `google_search` | `websearch_web_search_exa`, `webfetch` | `websearch_web_search_exa` |
| **Code Search** | — | `grep_app_searchGitHub` | `grep_app_searchGitHub` |
| **Documentation** | — | `context7_query-docs`, `context7_resolve-library-id` | `context7_query-docs` |
| **Web Fetch** | — | `webfetch` | `webfetch` |

**Error Message Template:**

```markdown
❌ Service 'google-search' is not available in this configuration.

Reason: Gemini for Google Cloud API has not been enabled in this project.

✅ Available alternatives:
  1. websearch_web_search_exa - LLM-optimized search results
  2. webfetch - Direct URL content fetching

Recommended: websearch_web_search_exa
Using: websearch_web_search_exa

[Continues execution with alternative]
```

📖 **Full protocol**: [`.scaffolding/agents/service-detection.md`](../agents/service-detection.md) | **ADR**: [0008](../docs/adr/0008-opencode-config-claude-code-reference.md)

---

## 🏗️ Architecture

This template adapts **Claude Code's five-layer architecture** (2025 hackathon winner):

| Layer | Claude Code | This Template | Status |
|-------|-------------|---------------|--------|
| **1. Agents** | Delegation system | Task delegation in `AGENTS.md` | ✅ Complete |
| **2. Skills** | Prompt modules | `.agents/skills/`, superpowers | ✅ Complete |
| **3. Commands** | Task mappings | Commands block in `AGENTS.md` | ✅ Complete |
| **4. Hooks** | Git automation | `.scaffolding/scripts/install-hooks.sh` | ✅ Complete |
| **5. Rules** | Guardrails | Service detection, conventions | ✅ Complete |

🔗 **Design decisions**: [ADR 0009](../adr/0009-reference-claude-code-architecture.md)

### Layer 1: Agents

**Purpose:** Delegate complex tasks to specialized agents

**Implementation:**
- Specialized agents in `.scaffolding/agents/agents/`
- 5 agents: `planner`, `architect`, `tdd-guide`, `code-reviewer`, `security-reviewer`
- Invoked via `task(subagent_type="...", ...)` in AGENTS.md

**Example:**
```typescript
task(
  subagent_type="planner",
  prompt="Plan user authentication system",
  run_in_background=false
)
```

### Layer 2: Skills

**Purpose:** Reusable implementation patterns

**Implementation:**
- Template skills in `.scaffolding/agents/skills/`
- User skills in `~/.config/opencode/skills/superpowers/`
- Project skills in `.agents/skills/`

**Usage:**
```
@use test-driven-development
User: "Implement login API"
```

### Layer 3: Commands

**Purpose:** Task-specific workflows combining agents and skills

**Implementation:**
- Documented in AGENTS.md "Commands" section
- 10 commands: `plan`, `code-review`, `build-fix`, `e2e`, `checkpoint`, `test-all`, `security-scan`, `analyze`, `refactor`, `document`

**Example:**
```
User: "Run security scan"
→ Invokes security-reviewer agent with security-review skill
```

### Layer 4: Hooks

**Purpose:** Automated quality checks (pre-commit, pre-push)

**Implementation:**
- Git hooks in `.scaffolding/scripts/install-hooks.sh`
- Pre-push: Enforce version bump before pushing to main
- Pre-commit: (Future) Lint, test, format checks

**Usage:**
```bash
./.scaffolding/scripts/install-hooks.sh
```

### Layer 5: Rules

**Purpose:** Guardrails and conventions

**Implementation:**
- Service Detection Protocol (check `config.toml` before calling services)
- Coding Conventions (in AGENTS.md)
- Documentation Standards (DOCUMENTATION_GUIDELINES.md)
- Module Loading Protocol (conditional documentation loading)

**Example:**
```toml
[services]
unsupported = ["google-search"]
→ AI agent uses websearch_web_search_exa instead
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     User Request                        │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │   Layer 5: Rules        │ (Guardrails)
        │   - Service Detection   │
        │   - Conventions         │
        │   - Module Loading      │
        └────────────┬────────────┘
                     │
        ┌────────────┴────────────┐
        │   Layer 4: Hooks        │ (Automation)
        │   - Pre-commit          │
        │   - Pre-push            │
        └────────────┬────────────┘
                     │
        ┌────────────┴────────────┐
        │   Layer 3: Commands     │ (Workflows)
        │   - plan, review, test  │
        └────────────┬────────────┘
                     │
        ┌────────────┴────────────┐
        │   Layer 2: Skills       │ (Patterns)
        │   - TDD, debugging      │
        └────────────┬────────────┘
                     │
        ┌────────────┴────────────┐
        │   Layer 1: Agents       │ (Delegation)
        │   - planner, architect  │
        └─────────────────────────┘
```

---

## 📚 Related Documentation

- **[AGENTS.md](../../AGENTS.md)** - AI agent instructions (primary entry point)
- **[README.md](../../README.md)** - Quick start guide (user-facing)
- **[CHANGELOG.md](../CHANGELOG.md)** - Template version history
- **[MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md)** - Upgrade from 1.x to 2.0.0
- **[ADR 0009](../adr/0009-reference-claude-code-architecture.md)** - Architecture decisions
- **[ADR 0012](../adr/0012-module-system-and-conditional-loading.md)** - Module System design
- **[SKILL_FORMAT_GUIDE.md](./SKILL_FORMAT_GUIDE.md)** - How to write skills
- **[DOCUMENTATION_GUIDELINES.md](./DOCUMENTATION_GUIDELINES.md)** - Documentation standards

---

## 📄 License

MIT License - See [LICENSE](../../LICENSE)

---

<div align="center">

**Technical Documentation | Version 3.0.0 | Last Updated: 2026-04-15**

[Documentation](../docs/) | [Changelog](../CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
