<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](./.scaffolding/VERSION)
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

- 🤖 **AI Agent 整合** - `AGENTS.md` + Skills 系統支援 OpenCode/Cursor/Claude
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

```bash
./.scaffolding/scripts/init-project.sh
```

**腳本會自動判斷你的情況：**
- **首次模式**（無 `.template-version` 檔案）→ 初始化新專案
- **更新模式**（`.template-version` 已存在）→ 更新模板配置

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
