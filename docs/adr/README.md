# Architecture Decision Records (ADRs)

這個目錄用來記錄**你的專案**的架構決策。

## Template 的 ADRs

Template 本身的 ADRs 在 `.scaffolding/docs/adr/`

## 如何使用

使用 `.scaffolding/docs/ADR_TEMPLATE.md` 作為模板創建新的 ADR：

```bash
# 創建新的 ADR
cp .scaffolding/docs/ADR_TEMPLATE.md docs/adr/NNNN-your-decision.md

# 編輯內容
# - 更新標題
# - 填寫背景脈絡
# - 記錄決策內容
# - 列出替代方案
# - 評估後果
```

## ADR 編號規則

- 使用 4 位數編號：`0001`, `0002`, `0003`, ...
- Template ADRs: `0001-0099` (保留給 template)
- 專案 ADRs: `0100+` (從 0100 開始)

## 範例

參考 `.scaffolding/docs/adr/` 中的範例：
- `0002-example-tech-stack-selection.md` - 技術選型
- `0003-example-api-design-principles.md` - API 設計
- `0004-example-testing-strategy.md` - 測試策略
