<div align="center">

<img src="./.template/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-1.13.0-blue.svg)](./.template/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

English | [繁體中文](./README.zh-TW.md)

</div>

---

## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Based on psychologist Lev Vygotsky's scaffolding theory - provides structure when you need it, remove it when you don't.

### Core Features

- 🤖 **AI Agent Integration** - `AGENTS.md` + Skills system for OpenCode/Cursor/Claude
- 📦 **Version Management** - Pre-push hooks enforce version updates
- 🌐 **Multi-language** - BCP 47 i18n for documentation
- 🛠️ **Smart Install/Update** - One script handles both new projects and updates

---

## 🚀 Installation & Update

### First Time: Use This Template

```bash
# 1. Click "Use this template" on GitHub → Clone your repo
# 2. Run installation script
./.template/scripts/init-project.sh
```

### Update Existing Project

```bash
# Same script auto-detects update mode
./.template/scripts/init-project.sh

# Updates:
# ✅ Consolidates agent configs (.claude, .roo → .agents)
# ✅ Updates template version
# ✅ Reinstalls Git hooks
```

---

## ⚙️ Configuration - AI Skills

### What are Skills?

**Skills** = Reusable AI workflows (like functions for AI agents)

Example: `test-driven-development`, `systematic-debugging`, `brainstorming`

### Where Your Skills Are

You already have **14 skills** available:
- 📍 `~/.config/opencode/skills/superpowers/` - User-level skills
- 📍 `.agents/skills/` - Project-specific skills (create if needed)

### How to Set Which Skills to Use

**Option 1: Auto-trigger via AGENTS.md** (Recommended)

Edit `AGENTS.md` to define skill triggers:

```markdown
### Default Skills for This Project

| Task Type | Skills | Trigger Keywords |
|-----------|--------|------------------|
| Feature Dev | `brainstorming` + `test-driven-development` | "add feature", "implement" |
| Bug Fixing | `systematic-debugging` | "bug", "error", "fix" |
```

**Option 2: Create Custom Bundles**

Edit `data/bundles.yaml`:

```yaml
- id: "my-bundle"
  skills:
    - name: "brainstorming"
    - name: "test-driven-development"
```

Use: `@use bundle:my-bundle`

**Option 3: Manual Load**

```
@use brainstorming
User: "Design an authentication system"
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

## 📄 License

MIT License - See [LICENSE](./LICENSE)

---

<div align="center">

**Based on Vygotsky's Scaffolding Theory | Powered by AI | For Developers**

[Documentation](./.template/docs/) | [Changelog](./.template/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
