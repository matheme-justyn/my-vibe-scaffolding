<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](./.scaffolding/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

English | [繁體中文](./README.zh-TW.md)

</div>

---

## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Based on psychologist Lev Vygotsky's scaffolding theory - provides structure when you need it, remove it when you don't.

<div align="center">
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
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

## 🎉 What's New in v2.0.0

Major upgrade with Module System, Academic Support, and enhanced AI workflows:

### 📚 Module System

Config-driven conditional documentation loading:

- **31 modules** organized by domain (frontend/backend/fullstack/academic)
- **6 core modules** always loaded: STYLE_GUIDE, GIT_WORKFLOW, ACADEMIC_WRITING, CITATION_MANAGEMENT, CONTEXT_FILE, AGENTS
- **25 conditional modules** loaded based on `config.toml` project type
- **Terminology system**: 183 standardized terms across software/academic domains
- **Hierarchical loading**: Universal → Domain-specific → Custom overrides

### 🎓 Academic Project Support

First-class support for research and academic writing:

- **Citation styles**: APA, MLA, Chicago, IEEE, ACM
- **Field-specific terminology**: Computer Science, Engineering, Social Science, Humanities
- **Academic writing standards**: Research methodology, literature review, thesis structure
- **ACADEMIC_WRITING.md** (777 lines): Complete academic writing guide
- **CITATION_MANAGEMENT.md** (741 lines): Citation and reference management

### 🌐 Multi-Language PR Templates

Smart pull request templates with language detection:

- **4 languages**: English, Traditional Chinese, Simplified Chinese, Japanese
- **Auto-detection**: Uses `config.toml` primary language setting
- **Custom instructions**: Language-specific contribution guidelines
- **Script**: `.scaffolding/scripts/generate-pr-template.sh`

### 🛠️ Enhanced Infrastructure

New tools for project setup and configuration:

- **configure-project-type.sh** (377 lines): Interactive project type selector
- **ADR 0012** (655 lines): Complete Module System architecture documentation
- **MIGRATION_GUIDE.md** (245 lines): Upgrade guide from 1.x to 2.0.0
- **Module Loading Protocol** in AGENTS.md: AI agent conditional loading guide

### 📖 Core Module Documentation

4 high-priority modules complete (26 low-priority modules planned for 2.1.x):

- **STYLE_GUIDE.md** (838 lines): Universal code style guide
- **GIT_WORKFLOW.md** (855 lines): Git workflow, commits, PR standards
- **ACADEMIC_WRITING.md** (777 lines): Academic writing guidelines
- **CITATION_MANAGEMENT.md** (741 lines): Citation and reference management

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

**Upgrading from 1.x?** See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for detailed instructions.

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

📖 **Full guide:** [`.scaffolding/docs/SKILLS_USAGE_GUIDE.md`](./.scaffolding/docs/SKILLS_USAGE_GUIDE.md)

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

## 🗂️ Why `.scaffolding/` Directory?

**Question**: Why `.scaffolding/` instead of `template/` or `scaffolding/`?

**Answer**: Intentional design choice based on:

1. **Hidden by default** - Leading dot indicates "system/framework" files
2. **Version control friendly** - Git shows `.scaffolding/` changes separately from project code
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

## 🏗️ Architecture

This template adapts **Claude Code's five-layer architecture** (2025 hackathon winner):

| Layer | Claude Code | This Template | Status |
|-------|-------------|---------------|--------|
| **1. Agents** | Delegation system | Task delegation in `AGENTS.md` | ✅ Complete |
| **2. Skills** | Prompt modules | `.agents/skills/`, superpowers | ✅ Complete |
| **3. Commands** | Task mappings | Commands block in `AGENTS.md` | ✅ Complete |
| **4. Hooks** | Git automation | `.scaffolding/scripts/install-hooks.sh` | ✅ Complete |
| **5. Rules** | Guardrails | Service detection, conventions | ✅ Complete |

🔗 **Design decisions**: [`docs/adr/0009-reference-claude-code-architecture.md`](./docs/adr/0009-reference-claude-code-architecture.md)

---

## 📄 License

MIT License - See [LICENSE](./LICENSE)

---

<div align="center">

**Based on Vygotsky's Scaffolding Theory | Powered by AI | For Developers**

[Documentation](./.scaffolding/docs/) | [Changelog](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
