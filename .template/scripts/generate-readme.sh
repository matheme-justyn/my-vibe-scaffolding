#!/usr/bin/env bash
# generate-readme.sh - Generate i18n-aware README files
# Content simplified for human users, detailed instructions in AGENTS.md for AI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_VERSION=$(cat "$PROJECT_ROOT/.template/VERSION")

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

generate_readme() {
    local locale="$1"
    local output_file
    
    if [[ "$locale" == "en-US" ]]; then
        output_file="$PROJECT_ROOT/README.md"
    else
        output_file="$PROJECT_ROOT/README.${locale}.md"
    fi
    
    local lang_switcher
    if [[ "$locale" == "en-US" ]]; then
        lang_switcher="English | [繁體中文](./README.zh-TW.md)"
    else
        lang_switcher="[English](./README.md) | 繁體中文"
    fi
    
    cat > "$output_file" <<EOF
<div align="center">

<img src="./.template/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-${TEMPLATE_VERSION}-blue.svg)](./.template/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

${lang_switcher}

</div>

---

EOF
    
    if [[ "$locale" == "en-US" ]]; then
        cat >> "$output_file" <<'EOF'
## 📌 What is This?

**AI-driven project scaffolding template** for quick project setup with best practices.

Based on psychologist Lev Vygotsky's scaffolding theory - provides structure when you need it, remove it when you don't.

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

## 📄 License

MIT License - See [LICENSE](./LICENSE)

---

<div align="center">

**Based on Vygotsky's Scaffolding Theory | Powered by AI | For Developers**

[Documentation](./.template/docs/) | [Changelog](./.template/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
EOF
    else
        cat >> "$output_file" <<'EOF'
## 📌 這是什麼？

**AI 驅動的專案鷹架模板** — 快速建立專案，遵循最佳實踐。

基於心理學家 Lev Vygotsky 的鷹架理論 — 需要時提供結構，不需要時移除。

### 核心功能

- 🤖 **AI Agent 整合** - `AGENTS.md` + Skills 系統，支援 OpenCode/Cursor/Claude
- 📦 **版本管理** - Pre-push hooks 強制版本更新
- 🌐 **多語言** - BCP 47 i18n 文件國際化
- 🛠️ **智慧設定** - 首次設定由 AI agent 自動處理

---

## 🚀 安裝

1. 在 GitHub 點擊 **"Use this template"** 建立你的 repository
2. Clone 你的新 repository
3. 開始使用 — 模板已經就緒

**注意**：首次設定在需要時會由 AI agent 自動處理

---

## ⚙️ 設定 - AI Skills

### Skills 是什麼？

**Skills** = 可重複使用的 AI 工作流程（就像 AI agent 的函數）

範例：`test-driven-development`, `systematic-debugging`, `brainstorming`

### 你的 Skills 在哪裡？

你已經有 **14 個 skills** 可用：
- 📍 `~/.config/opencode/skills/superpowers/` - 使用者層級 skills
- 📍 `.agents/skills/` - 專案特定 skills（需要時建立）

### 如何使用 Skills？

**方法 1: 透過 AGENTS.md 自動觸發**（推薦）

Skills 會根據任務類型自動載入。觸發關鍵字請參考 `AGENTS.md`。

**方法 2: 手動載入**

```
@use brainstorming
User: "設計認證系統"
```

**方法 3: 使用 Bundles**

```
@use bundle:backend-dev
```

### 可用的 Skills

- `brainstorming` - 功能構思
- `test-driven-development` - TDD 工作流程
- `systematic-debugging` - Bug 診斷
- `requesting-code-review` - 程式碼審查
- `using-git-worktrees` - Git 工作流程
- ...還有 9 個

📖 **完整指南：** [`.template/docs/SKILLS_USAGE_GUIDE.md`](./.template/docs/SKILLS_USAGE_GUIDE.md)

---

## 🎯 技術堆疊

為什麼選這些技術？

| 技術 | 原因 | 解決的問題 |
|------|------|-----------|
| **OpenCode** (Open-source AI) | 75+ 模型，CLI 優先 | 避免供應商鎖定 |
| **AGENTS.md 標準** | 跨工具相容 | AI 理解專案慣例 |
| **Skills 系統** | 可重複使用的工作流程 | 編碼最佳實踐 |
| **Bundles & Workflows** | 角色導向集合 | 快速載入情境 |

我們使用 [superpowers](https://github.com/ohmyopencode/superpowers) — 社群驅動的 AI 工作流程。

---

## 📄 授權

MIT License - 詳見 [LICENSE](./LICENSE)

---

<div align="center">

**基於 Vygotsky 鷹架理論 | AI 驅動 | 為開發者打造**

[文件](./.template/docs/) | [Changelog](./.template/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
EOF
    fi
    
    echo -e "${GREEN}✓ Generated: $output_file${NC}"
}

main() {
    echo -e "${BLUE}Generating README files...${NC}"
    generate_readme "en-US"
    generate_readme "zh-TW"
    cp "$PROJECT_ROOT/README.md" "$PROJECT_ROOT/.template/README.md"
    cp "$PROJECT_ROOT/README.zh-TW.md" "$PROJECT_ROOT/.template/README.zh-TW.md"
    echo -e "${GREEN}✓ All README files generated and synced!${NC}"
}

main "$@"
