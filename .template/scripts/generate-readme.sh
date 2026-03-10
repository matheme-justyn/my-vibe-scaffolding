#!/usr/bin/env bash
# generate-readme.sh - Generate i18n-aware README files from .template/i18n/locales/
# Usage: ./generate-readme.sh [locale]
#   If no locale specified, generates all locales

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
I18N_DIR="$PROJECT_ROOT/.template/i18n/locales"
TEMPLATE_VERSION=$(cat "$PROJECT_ROOT/.template/VERSION")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse TOML value (simple parser for string values)
parse_toml_value() {
    local file="$1"
    local key="$2"
    
    # Extract value after = and remove quotes
    grep "^${key} = " "$file" | sed 's/^[^=]*= *"\(.*\)" *$/\1/' | head -1
}

# Generate README for a specific locale
generate_readme() {
    local locale="$1"
    local readme_toml="$I18N_DIR/$locale/readme.toml"
    
    if [[ ! -f "$readme_toml" ]]; then
        echo -e "${RED}✗ Locale '$locale' not found: $readme_toml${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Generating README for locale: $locale${NC}"
    
    # Determine output file
    local output_file
    if [[ "$locale" == "en-US" ]]; then
        output_file="$PROJECT_ROOT/README.md"
    else
        output_file="$PROJECT_ROOT/README.${locale}.md"
    fi
    
    # Language switcher
    local lang_switcher
    if [[ "$locale" == "en-US" ]]; then
        lang_switcher="English | [繁體中文](./README.zh-TW.md)"
    else
        lang_switcher="[English](./README.md) | 繁體中文"
    fi
    
    # Parse translations
    local what_is_this=$(parse_toml_value "$readme_toml" "title" | grep -A 1 "\[concept\]" | tail -1 || echo "What is This?")
    
    # Generate README content
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
    
    # Add content from TOML
    if [[ "$locale" == "en-US" ]]; then
        cat >> "$output_file" <<'EOF'
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

| Task Type | Skills | Trigger Keywords |
|-----------|--------|------------------|
| Feature Dev | `brainstorming` + `test-driven-development` | "add feature", "implement" |
| Bug Fixing | `systematic-debugging` | "bug", "error", "fix" |

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
EOF
    else
        # Chinese version
        cat >> "$output_file" <<'EOF'
## 📌 這是什麼？

**AI 驅動的專案鷹架模板** — 快速建立專案，遵循最佳實踐。

基於心理學家 Lev Vygotsky 的鷹架理論 — 需要時提供結構，不需要時移除。

### 核心功能

- 🤖 **AI Agent 整合** - `AGENTS.md` + Skills 系統，支援 OpenCode/Cursor/Claude
- 📦 **版本管理** - Pre-push hooks 強制版本更新
- 🌐 **多語言** - BCP 47 i18n 文件國際化
- 🛠️ **智慧安裝/更新** - 單一腳本處理安裝和更新

---

## 🚀 安裝與更新

### 首次使用：Use This Template

```bash
# 1. 在 GitHub 點擊 "Use this template" → Clone 你的 repo
# 2. 執行安裝腳本
./.template/scripts/init-project.sh
```

### 更新既有專案

```bash
# 同一個腳本自動偵測更新模式
./.template/scripts/init-project.sh

# 更新內容：
# ✅ 整併 agent 配置（.claude, .roo → .agents）
# ✅ 更新 template 版本
# ✅ 重新安裝 Git hooks
```

---

## ⚙️ 設定 - AI Skills

### Skills 是什麼？

**Skills** = 可重複使用的 AI 工作流程（就像 AI agent 的函數）

範例：`test-driven-development`, `systematic-debugging`, `brainstorming`

### 你的 Skills 在哪裡？

你已經有 **14 個 skills** 可用：
- 📍 `~/.config/opencode/skills/superpowers/` - 使用者層級 skills
- 📍 `.agents/skills/` - 專案特定 skills（需要時建立）

### 如何設定要用哪些 Skills？

**方法 1: 透過 AGENTS.md 自動觸發**（推薦）

編輯 `AGENTS.md` 定義 skill 觸發條件：

| 任務類型 | Skills | 觸發關鍵字 |
|---------|--------|-----------|
| 功能開發 | `brainstorming` + `test-driven-development` | "新增功能", "實作" |
| Bug 修復 | `systematic-debugging` | "bug", "錯誤", "修正" |

**方法 2: 建立自訂 Bundles**

編輯 `data/bundles.yaml`：

```yaml
- id: "my-bundle"
  skills:
    - name: "brainstorming"
    - name: "test-driven-development"
```

使用：`@use bundle:my-bundle`

**方法 3: 手動載入**

```
@use brainstorming
User: "設計認證系統"
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

# Main logic
main() {
    if [[ $# -eq 0 ]]; then
        # Generate all locales
        echo -e "${BLUE}Generating README files for all locales...${NC}"
        echo ""
        
        generate_readme "en-US"
        generate_readme "zh-TW"
        
        echo ""
        echo -e "${GREEN}✓ All README files generated successfully!${NC}"
    else
        # Generate specific locale
        generate_readme "$1"
    fi
}

main "$@"
