<div align="center">

<img src="./.scaffolding/assets/images/20260225_vibe-scaffolding-logo.png" alt="Vibe Scaffolding Logo" width="400"/>

# My Vibe Scaffolding

[![Version](https://img.shields.io/badge/version-3.2.0-blue.svg)](./.scaffolding/VERSION)
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

**統一 AI Prompt（適用所有情境）：**

```
請從 https://github.com/matheme-justyn/my-vibe-scaffolding 導入鷹架系統到目前專案
```

**AI 會自動偵測情境並處理：**

### 情境 A：現有專案導入鷹架

如果目前目錄已有專案檔案（`.git/`、`package.json` 等）：
1. 從 GitHub 下載 `.scaffolding/` 目錄
2. 下載 `AGENTS.md`、`config.toml.example`
3. 執行 `./.scaffolding/scripts/init-project.sh`
4. 腳本偵測無 `.template-version` → **首次安裝模式**

### 情境 B：建立全新專案

如果要建立全新專案：
1. 在 GitHub 點擊 **"Use this template"**
2. Clone 你的新 repository
3. 執行 `./.scaffolding/scripts/init-project.sh`
4. 腳本偵測無 `.template-version` → **首次安裝模式**

**核心優勢**：一個 prompt 搞定所有情境 — AI 自動處理剩下的

---

## ⚙️ 腳本運作方式

`init-project.sh` 腳本會智慧偵測你的情況：

**首次模式**（無 `.template-version` 檔案）：
- 詢問專案資訊
- 建立 VERSION、README.md、LICENSE
- 設定 Git hooks
- 建立 `.template-version` 追蹤使用的模板版本

**更新模式**（`.template-version` 已存在）：
- 比對目前版本與模板版本
- 整併 agent 配置（`.claude`、`.roo` → `.agents`）
- 重新安裝 Git hooks（可能有新功能）
- 更新 `.template-version`

**何時手動執行：**
- 從 template 建立新專案後
- 想要更新模板功能時
- 需要整併分散的 agent 配置時

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
