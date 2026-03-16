#!/usr/bin/env bash
# generate-readme.sh - Generate i18n-aware README files
# Content simplified for human users, detailed instructions in AGENTS.md for AI

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_VERSION=$(cat "$PROJECT_ROOT/.scaffolding/VERSION")

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

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-${TEMPLATE_VERSION}-blue.svg)](./.scaffolding/VERSION)
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
EOF
    else
        cat >> "$output_file" <<'EOF'
## 📌 這是什麼？

**AI 驅動的專案鷹架模板** — 快速建立專案，遵循最佳實踐。

基於心理學家 Lev Vygotsky 的鷹架理論 — 需要時提供結構，不需要時移除。

<div align="center">
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
</div>
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

## 🎉 v2.0.0 新功能

重大升級：Module System、學術專案支援、強化 AI 工作流程：

### 📚 模組系統

基於配置的條件式文件載入：

- **31 個模組** 依領域組織（frontend/backend/fullstack/academic）
- **6 個核心模組** 永遠載入：STYLE_GUIDE、GIT_WORKFLOW、ACADEMIC_WRITING、CITATION_MANAGEMENT、CONTEXT_FILE、AGENTS
- **25 個條件模組** 根據 `config.toml` 專案類型載入
- **術語系統**：183 個標準化術語（軟體/學術領域）
- **階層式載入**：通用 → 領域專用 → 自訂覆蓋

### 🎓 學術專案支援

研究和學術寫作的一流支援：

- **引用格式**：APA、MLA、Chicago、IEEE、ACM
- **領域專用術語**：資訊科學、工程、社會科學、人文
- **學術寫作標準**：研究方法、文獻回顧、論文結構
- **ACADEMIC_WRITING.md** (777 行)：完整學術寫作指南
- **CITATION_MANAGEMENT.md** (741 行)：引用與參考文獻管理

### 🌐 多語言 PR 模板

智慧型 Pull Request 模板與語言偵測：

- **4 種語言**：英文、繁體中文、簡體中文、日文
- **自動偵測**：使用 `config.toml` 主要語言設定
- **自訂說明**：語言專用貢獻指南
- **腳本**：`.scaffolding/scripts/generate-pr-template.sh`

### 🛠️ 強化基礎設施

專案設定與配置的新工具：

- **configure-project-type.sh** (377 行)：互動式專案類型選擇器
- **ADR 0012** (655 行)：完整 Module System 架構文件
- **MIGRATION_GUIDE.md** (245 行)：1.x 到 2.0.0 升級指南
- **Module Loading Protocol** 於 AGENTS.md：AI agent 條件載入指南

### 📖 核心模組文件

4 個高優先級模組完成（26 個低優先級模組規劃於 2.1.x）：

- **STYLE_GUIDE.md** (838 行)：通用程式碼風格指南
- **GIT_WORKFLOW.md** (855 行)：Git 工作流程、提交、PR 標準
- **ACADEMIC_WRITING.md** (777 行)：學術寫作指南
- **CITATION_MANAGEMENT.md** (741 行)：引用與參考文獻管理

### 🚀 v2.0.0 快速開始

```bash
# 1. 設定專案類型（互動式）
./.scaffolding/scripts/configure-project-type.sh

# 2. 在 config.toml 中配置你的偏好
# 對於學術專案，設定：
#   [academic]
#   citation_style = "apa"
#   field = "computer_science"

# 3. 生成 PR 模板（自動偵測語言）
./.scaffolding/scripts/generate-pr-template.sh

# 4. 開始編碼 - AI agent 會自動載入相關模組
```

**從 1.x 升級？** 參閱 [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) 取得詳細說明。


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

📖 **完整指南：** [`.scaffolding/docs/SKILLS_USAGE_GUIDE.md`](./.scaffolding/docs/SKILLS_USAGE_GUIDE.md)

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

## 🗂️ 為什麼使用 `.scaffolding/` 目錄？

**問題**：為什麼用 `.scaffolding/` 而非 `template/` 或 `scaffolding/`？

**答案**：基於以下考量的刻意設計：

1. **預設隱藏** - 前導點表示「系統/框架」檔案
2. **版本控制友善** - Git 將 `.scaffolding/` 變更與專案程式碼分開顯示
3. **AI agent 清晰** - Agent 能區分「模板結構」vs「專案檔案」
4. **業界先例** - 遵循 `.github/`、`.vscode/`、`.husky/` 模式

**考慮過的替代方案**：`template/`（已拒絕 - 太顯眼，與專案模板混淆）

---

## 🛡️ 服務偵測

**問題**：AI agent 嘗試呼叫不可用的服務（例如未配置 API 時呼叫 `google-search`）

**解決方案**：在 `config.toml` 中宣告式管理服務可用性：

```toml
[services]
unsupported = ["google-search", "google_search"]

[services.alternatives]
google-search = ["websearch_web_search_exa", "webfetch"]
```

**AI Agent 協定**：
1. 呼叫任何外部服務前先檢查 `config.toml`
2. 若服務在 `unsupported` 清單 → 使用替代方案
3. 通知使用者替代情況

📖 **完整協定**：[`.agents/service-detection.md`](./.agents/service-detection.md)

---

## 🏗️ 架構

本模板改編自 **Claude Code 的五層架構**（2025 hackathon 冠軍）：

| 層級 | Claude Code | 本模板 | 狀態 |
|------|-------------|--------|------|
| **1. Agents** | 委派系統 | `AGENTS.md` 中的任務委派 | ✅ 完成 |
| **2. Skills** | Prompt 模組 | `.agents/skills/`、superpowers | ✅ 完成 |
| **3. Commands** | 任務映射 | `AGENTS.md` 中的 Commands 區塊 | ✅ 完成 |
| **4. Hooks** | Git 自動化 | `.scaffolding/scripts/install-hooks.sh` | ✅ 完成 |
| **5. Rules** | 防護機制 | 服務偵測、慣例規範 | ✅ 完成 |

🔗 **設計決策**：[`docs/adr/0009-reference-claude-code-architecture.md`](./docs/adr/0009-reference-claude-code-architecture.md)

---

## 📄 授權

MIT License - 詳見 [LICENSE](./LICENSE)

---

<div align="center">

**基於 Vygotsky 鷹架理論 | AI 驅動 | 為開發者打造**

[文件](./.scaffolding/docs/) | [Changelog](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
EOF
    fi
    
    echo -e "${GREEN}✓ Generated: $output_file${NC}"
}

main() {
    echo -e "${BLUE}Generating README files...${NC}"
    generate_readme "en-US"
    generate_readme "zh-TW"
    cp "$PROJECT_ROOT/README.md" "$PROJECT_ROOT/.scaffolding/README.md"
    cp "$PROJECT_ROOT/README.zh-TW.md" "$PROJECT_ROOT/.scaffolding/README.zh-TW.md"
    echo -e "${GREEN}✓ All README files generated and synced!${NC}"
}

main "$@"
