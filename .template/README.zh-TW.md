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

<div align="center">
<img src="./.template/assets/images/20260225_vibe-scaffolding-illustration-american.png" alt="American Style Illustration" width="300"/>
<img src="./.template/assets/images/20260225_vibe-scaffolding-illustration-japanese.png" alt="Japanese Style Illustration" width="300"/>
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

## 🗂️ 為什麼使用 `.template/` 目錄？

**問題**：為什麼用 `.template/` 而非 `template/` 或 `scaffolding/`？

**答案**：基於以下考量的刻意設計：

1. **預設隱藏** - 前導點表示「系統/框架」檔案
2. **版本控制友善** - Git 將 `.template/` 變更與專案程式碼分開顯示
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
| **4. Hooks** | Git 自動化 | `.template/scripts/install-hooks.sh` | ✅ 完成 |
| **5. Rules** | 防護機制 | 服務偵測、慣例規範 | ✅ 完成 |

🔗 **設計決策**：[`docs/adr/0009-reference-claude-code-architecture.md`](./docs/adr/0009-reference-claude-code-architecture.md)

---

## 📄 授權

MIT License - 詳見 [LICENSE](./LICENSE)

---

<div align="center">

**基於 Vygotsky 鷹架理論 | AI 驅動 | 為開發者打造**

[文件](./.template/docs/) | [Changelog](./.template/CHANGELOG.md) | [GitHub](https://github.com/matheme-justyn/my-vibe-scaffolding)

</div>
