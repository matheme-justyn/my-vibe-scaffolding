<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-3.1.0-blue.svg)](./.scaffolding/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

English | [繁體中文](./README.zh-TW.md)

</div>

---

## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Based on psychologist Lev Vygotsky's scaffolding theory — provides structure when you need it, remove it when you don't.

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

---

## ⚙️ Unified Setup Command

**One command for everything:**

```bash
./.scaffolding/scripts/init-project.sh
```

**The script automatically detects your situation:**
- **First-time mode** (no `.template-version` file) → Initialize new project
- **Update mode** (`.template-version` exists) → Update template configuration

**When to run this command:**
- User says: "setup project", "initialize", "configure"
- User says: "update template", "upgrade", "sync template"
- Missing required files detected (VERSION, git hooks, etc.)
- User wants latest template features

**Key benefit**: You and AI agents don't need to remember different commands for different scenarios.

---

## 📖 Documentation

- 📖 **[Full Features](./.scaffolding/docs/FEATURES.md)** - Complete v2.0.0 technical documentation
- 🤖 **[AGENTS.md](./AGENTS.md)** - AI agent instructions and coding conventions
- 📝 **[CHANGELOG.md](./.scaffolding/CHANGELOG.md)** - Version history and changes

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

[Documentation](./.scaffolding/docs/) | [Changelog](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
