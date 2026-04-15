#!/usr/bin/env bash
# generate-readme.sh - Generate simplified i18n-aware README files
# Reads from .scaffolding/i18n/locales/{locale}/readme.toml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_VERSION=$(cat "$PROJECT_ROOT/.scaffolding/VERSION")

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to read TOML value (simple parser for our use case)
get_toml_value() {
    local file="$1"
    local key="$2"
    # Extract value after = and remove quotes
    grep "^${key} = " "$file" | sed 's/^[^=]*= *"\(.*\)"$/\1/' | head -1
}

generate_readme_en() {
    local output_file="$PROJECT_ROOT/README.md"
    local toml_file="$PROJECT_ROOT/.scaffolding/i18n/locales/en-US/readme.toml"
    
    cat > "$output_file" <<EOF
<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-${TEMPLATE_VERSION}-blue.svg)](./.scaffolding/VERSION)
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

- 🤖 **AI Agent Integration** - \`AGENTS.md\` + Skills system for OpenCode/Cursor/Claude
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

\`\`\`bash
./.scaffolding/scripts/init-project.sh
\`\`\`

**The script automatically detects your situation:**
- **First-time mode** (no \`.template-version\` file) → Initialize new project
- **Update mode** (\`.template-version\` exists) → Update template configuration

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
EOF

    echo -e "${GREEN}✓ Generated: ${output_file}${NC}"
}

generate_readme_zh() {
    local output_file="$PROJECT_ROOT/README.zh-TW.md"
    local toml_file="$PROJECT_ROOT/.scaffolding/i18n/locales/zh-TW/readme.toml"
    
    cat > "$output_file" <<EOF
<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-${TEMPLATE_VERSION}-blue.svg)](./.scaffolding/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

[English](./README.md) | 繁體中文

</div>

---

## 📌 這是什麼？

**AI 驅動的專案鷹架模板**，用於快速建立專案並遵循最佳實踐。

基於心理學家 Lev Vygotsky 的鷹架理論 — 在需要時提供結構支援，不需要時可移除。

<div align="center">
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
</div>

### 核心特色

- 🤖 **AI Agent 整合** - \`AGENTS.md\` + Skills 系統支援 OpenCode/Cursor/Claude
- 📦 **版本管理** - Pre-push hooks 強制執行版本更新
- 🌐 **多語言支援** - BCP 47 i18n 文件國際化
- 🛠️ **智慧設定** - AI agent 自動處理首次設定

---

## 🚀 安裝

1. 在 GitHub 點擊 **"Use this template"** 建立你的 repository
2. Clone 你的新 repository
3. 開始使用 — 模板已經就緒

**注意**：首次設定在需要時會由 AI agent 自動處理

---

## ⚙️ 統一設定命令

**一個命令搞定所有事：**

\`\`\`bash
./.scaffolding/scripts/init-project.sh
\`\`\`

**腳本會自動判斷你的情況：**
- **首次模式**（無 \`.template-version\` 檔案）→ 初始化新專案
- **更新模式**（\`.template-version\` 已存在）→ 更新模板配置

**何時執行此命令：**
- 說「setup project」、「initialize」、「configure」
- 說「update template」、「upgrade」、「sync template」
- 偵測到缺少必要檔案（VERSION、git hooks 等）
- 想要最新的模板功能

**核心優勢**：你和 AI agent 不需要記住不同情境的不同命令。

---

## 📖 文件

- 📖 **[完整功能說明](./.scaffolding/docs/FEATURES.md)** - 完整的 v2.0.0 技術文件
- 🤖 **[AGENTS.md](./AGENTS.md)** - AI agent 指令和編碼規範
- 📝 **[CHANGELOG.md](./.scaffolding/CHANGELOG.md)** - 版本歷史和變更記錄

---

## 🎯 技術棧

為什麼選擇這些技術？

| 技術 | 原因 | 解決的問題 |
|------|------|-----------|
| **OpenCode**（開源 AI）| 75+ 模型，CLI 優先 | 避免供應商鎖定 |
| **AGENTS.md 標準** | 跨工具相容 | AI 理解專案慣例 |
| **Skills 系統** | 可重用的工作流程 | 編碼最佳實踐 |
| **Bundles & Workflows** | 角色導向的集合 | 快速載入上下文 |

我們使用 [superpowers](https://github.com/ohmyopencode/superpowers) - 社群驅動的 AI 工作流程。

---

## 📄 授權

MIT 授權 - 參閱 [LICENSE](./LICENSE)

---

<div align="center">

**基於 Vygotsky 鷹架理論 | AI 驅動 | 為開發者設計**

[文件](./.scaffolding/docs/) | [變更記錄](./.scaffolding/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
EOF

    echo -e "${GREEN}✓ Generated: ${output_file}${NC}"
}

sync_to_scaffolding() {
    echo -e "${BLUE}Syncing to .scaffolding/ directory...${NC}"
    cp "$PROJECT_ROOT/README.md" "$PROJECT_ROOT/.scaffolding/README.md"
    cp "$PROJECT_ROOT/README.zh-TW.md" "$PROJECT_ROOT/.scaffolding/README.zh-TW.md"
    echo -e "${GREEN}✓ Synced to .scaffolding/${NC}"
}

main() {
    echo -e "${BLUE}Generating README files...${NC}"
    generate_readme_en
    generate_readme_zh
    sync_to_scaffolding
    echo -e "${GREEN}✓ All README files generated and synced!${NC}"
}

main
