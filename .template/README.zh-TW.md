<div align="center">

<img src="./.template/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-1.13.0-blue.svg)](./.template/VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

[English](./README.md) | 繁體中文

</div>

---

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
