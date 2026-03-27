# Skills 衝突分析報告

**日期**：2025-01-XX  
**版本**：v3.0.0 規劃階段  
**目的**：盤點所有技能，找出重複功能與潛在衝突

---

## 📊 完整技能清單

### 現有技能（v2.x）

#### ECC Skills（.agents/skills/）- 15 個

**Universal（5）**：
1. `tdd-workflow` - TDD 工作流程
2. `verification-loop` - 系統化驗證檢查表
3. `security-review` - 安全審查清單
4. `api-design` - REST API 設計模式
5. `coding-standards` - 程式碼風格規範

**Backend（3）**：
6. `backend-patterns` - Node.js 後端模式
7. `database-optimization` - 資料庫查詢優化
8. `error-handling` - 錯誤處理模式

**Frontend（3）**：
9. `frontend-patterns` - React/Next.js 架構
10. `react-hooks` - React Hooks 模式
11. `component-design` - 元件設計模式

**Testing（2）**：
12. `e2e-testing` - Playwright E2E 測試
13. `unit-testing` - Jest/Vitest 單元測試

**Other（2）**：
14. `content-engine` - 內容創作工作流程
15. `market-research` - 市場分析模式

#### Superpowers Skills（~/.config/opencode/skills/superpowers/）- 14 個

1. `using-superpowers` - 技能系統使用指南
2. `brainstorming` - 功能構思與規劃
3. `test-driven-development` - TDD 嚴格執行（Iron Law）
4. `systematic-debugging` - 系統化除錯
5. `using-git-worktrees` - Git worktree 隔離開發
6. `executing-plans` - 執行實作計畫
7. `finishing-a-development-branch` - 完成開發分支
8. `dispatching-parallel-agents` - 平行 agent 調度
9. `requesting-code-review` - 請求程式碼審查
10. `receiving-code-review` - 接收程式碼審查
11. `subagent-driven-development` - Subagent 驅動開發
12. `verification-before-completion` - 完成前強制驗證（Iron Law）
13. `writing-plans` - 撰寫實作計畫
14. `writing-skills` - 撰寫技能文件

### 計畫新增（v3.0.0）

**SDD Skills（3）**：
1. `sdd-propose` - 建立變更提案
2. `sdd-apply` - 套用規格實作
3. `sdd-archive` - 封存已完成變更

---

## ⚠️ 重複功能衝突分析

### 衝突 1：TDD 工作流程（嚴重衝突）

| 對比項目 | `.agents/skills/universal/tdd-workflow` | `superpowers/test-driven-development` |
|---------|----------------------------------------|---------------------------------------|
| **來源** | ECC (everything-claude-code) | Superpowers |
| **風格** | 指導性（Guidance） | 強制性（Iron Law） |
| **核心規則** | "Enforce TDD with 80%+ coverage" | "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" |
| **違規處理** | 建議重寫 | **刪除程式碼，重新開始**（不留參考） |
| **例外處理** | 提供彈性（視專案調整） | **無例外**（拋棄式原型要問人類） |
| **Red-Green-Refactor** | 有流程圖，但非強制 | **嚴格循環**（違反字面 = 違反精神） |
| **長度** | 441 行 | ~200 行 |

**衝突點**：
- ❌ **ECC**: "可以視專案需求調整 TDD 嚴格度"
- ❌ **Superpowers**: "想跳過 TDD？那是理性化藉口（rationalization）"

**影響**：
- 🔴 **高度衝突** - AI 不知道該聽誰的
- 🔴 AI 可能選擇「較寬鬆」的 ECC 版本（違背 Superpowers 理念）

**建議處理**：
```
選項 A：保留 Superpowers 版本，刪除 ECC 版本
選項 B：合併成單一版本（以 Superpowers 的 Iron Law 為準）
選項 C：明確優先順序（Superpowers > ECC，AGENTS.md 明確聲明）
```

---

### 衝突 2：驗證檢查（中度衝突）

| 對比項目 | `.agents/skills/universal/verification-loop` | `superpowers/verification-before-completion` |
|---------|---------------------------------------------|---------------------------------------------|
| **來源** | ECC | Superpowers |
| **風格** | 檢查表（Checklist） | 強制守門（Gate Function） |
| **核心規則** | "Systematic verification checklist" | "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" |
| **檢查時機** | 完成任務前、提交前、部署前 | **每次聲稱完成前**（更頻繁） |
| **證據要求** | "確認通過測試" | **在同一訊息中執行命令** |
| **長度** | 156 行 | ~150 行 |

**衝突點**：
- ⚠️ **ECC**: "可以依序檢查清單項目"
- ⚠️ **Superpowers**: "沒有在這個訊息執行命令 = 說謊（lying）"

**影響**：
- 🟡 **中度衝突** - 規則嚴格度不同
- 🟡 AI 可能選擇「較寬鬆」的檢查表版本

**建議處理**：
```
選項 A：保留 Superpowers 版本（更嚴格）
選項 B：合併（以 Superpowers 的 Iron Law 為準，但保留 ECC 的檢查清單細節）
選項 C：分工（verification-loop = 檢查清單內容，verification-before-completion = 執行規則）
```

---

### 衝突 3：v3.0.0 新增 SDD Skills 與現有 Skills

#### sdd-propose vs brainstorming（功能重疊）

| 對比項目 | `sdd-propose`（計畫新增） | `superpowers/brainstorming` |
|---------|--------------------------|----------------------------|
| **用途** | 建立正式變更提案 | 功能構思與設計 |
| **產出** | proposal.md + design.md + tasks.md | 設計討論 + 方案評估 |
| **時機** | 實作前（spec-first） | 實作前（brainstorming） |
| **格式** | OpenSpec 格式（Delta Specs） | 自由格式 |

**衝突點**：
- ⚠️ 兩者都在「實作前階段」
- ⚠️ AI 不知道該用哪一個

**建議處理**：
```
選項 A：sdd-propose 內部調用 brainstorming（先 brainstorming → 再正式化成 proposal）
選項 B：明確分工（brainstorming = 探索階段，sdd-propose = 文件化階段）
選項 C：合併（brainstorming 直接輸出 OpenSpec 格式）
```

#### sdd-apply vs test-driven-development（功能重疊）

| 對比項目 | `sdd-apply`（計畫新增） | `superpowers/test-driven-development` |
|---------|------------------------|--------------------------------------|
| **用途** | 從規格實作 | 測試驅動實作 |
| **前置條件** | 必須有 proposal.md | 不需要 proposal |
| **工作流程** | 載入 spec → 實作 | 寫測試 → 實作 |

**衝突點**：
- ⚠️ 都在「實作階段」
- ⚠️ sdd-apply 沒有強制 TDD？還是內部調用 TDD？

**建議處理**：
```
選項 A：sdd-apply 內部強制調用 test-driven-development（spec + TDD 一起）
選項 B：明確流程（sdd-apply 負責讀 spec，TDD 負責寫測試）
選項 C：合併（sdd-apply = spec-driven + test-driven）
```

---

## 🎯 技能優先順序建議

### 優先順序規則

根據設計理念，建議優先順序：

```
1. Superpowers (Iron Laws)     ← 最高優先（強制規則）
2. SDD Skills (v3.0.0)          ← 第二優先（工作流程）
3. ECC Skills (Implementation)  ← 第三優先（實作細節）
```

### 載入順序

```
AGENTS.md → superpowers → SDD → ECC → user-project
           (Iron Laws)   (Workflow) (Details) (Override)
```

### 衝突解決原則

**當同功能技能衝突時**：

```
IF superpowers 有 Iron Law：
    → 使用 superpowers 版本（不可妥協）
ELSE IF SDD workflow 定義流程：
    → 使用 SDD 版本（工作流程）
ELSE：
    → 使用 ECC 版本（實作細節）
```

---

## 📋 建議處理方案（完整清單）

### 立即處理（高優先）

#### 1. TDD 衝突（嚴重）

**決策**：保留 Superpowers 版本，刪除 ECC 版本

**理由**：
- Superpowers 的 Iron Law 是核心理念
- ECC 版本過於寬鬆，會導致 AI 找藉口

**行動**：
```bash
# 刪除 ECC 版本
rm .agents/skills/universal/tdd-workflow.md

# 在 AGENTS.md 明確聲明
TDD 使用 superpowers/test-driven-development（唯一版本）
```

#### 2. Verification 衝突（中度）

**決策**：保留兩個，但明確分工

**分工**：
- `verification-before-completion`（Superpowers）：**執行規則**（Iron Law）
- `verification-loop`（ECC）：**檢查清單內容**（What to check）

**行動**：
```markdown
# AGENTS.md 明確說明
使用順序：
1. verification-before-completion - 強制執行驗證
2. verification-loop - 參考檢查清單（build, test, lint, runtime）
```

#### 3. SDD + Brainstorming 整合

**決策**：sdd-propose 內部調用 brainstorming

**流程**：
```
使用者：「新增功能 X」
↓
AI：載入 sdd-propose
↓
sdd-propose 內部：
  1. 調用 brainstorming（探索階段）
  2. 將 brainstorming 結果正式化
  3. 輸出 proposal.md（OpenSpec 格式）
```

#### 4. SDD + TDD 整合

**決策**：sdd-apply 強制調用 test-driven-development

**流程**：
```
sdd-apply:
  1. 載入 proposal.md + design.md
  2. 拆解成任務清單
  3. 每個任務：
     → 調用 test-driven-development
     → 寫測試 → 實作 → Refactor
  4. 追蹤 Delta Changes（ADDED/MODIFIED/REMOVED）
```

---

### 中期處理（需討論）

#### 5. 目錄結構調整

**問題**：`.agents/` 會跟專案自己的 agents 混在一起

**方案**：全部搬進 `.scaffolding/agents/`（已在前面討論）

#### 6. 技能命名衝突

**潛在問題**：
- `tdd-workflow`（ECC）vs `test-driven-development`（Superpowers）
- 使用者可能搞混

**建議**：
- 統一命名規範
- 刪除重複的低優先版本

---

### 長期優化（Phase 2+）

#### 7. 技能合併計畫

**候選合併清單**：

| 保留（主要版本） | 合併進來（次要版本） | 理由 |
|----------------|-------------------|-----|
| `test-driven-development` | `tdd-workflow` | 刪除 ECC 版本 |
| `verification-before-completion` | `verification-loop` 的檢查清單 | 保留 Iron Law，吸收檢查清單 |
| `sdd-propose` | `brainstorming` 流程 | SDD 流程包含 brainstorming |

#### 8. 文件標準化

**問題**：
- Superpowers 用 `Iron Law` 語氣
- ECC 用 `Best Practices` 語氣
- 不一致會讓 AI 混淆

**建議**：
- 統一成 Superpowers 風格（嚴格、不妥協）
- 所有技能都有明確的 "MUST" / "MUST NOT"

---

## 🔍 技能依賴關係圖

```
using-superpowers (入口)
  ├─→ brainstorming (功能構思)
  │    └─→ sdd-propose (正式提案) [v3.0.0]
  │         └─→ sdd-apply (實作規格) [v3.0.0]
  │              ├─→ test-driven-development (TDD Iron Law)
  │              │    ├─→ unit-testing (ECC)
  │              │    └─→ e2e-testing (ECC)
  │              ├─→ backend-patterns (ECC)
  │              ├─→ frontend-patterns (ECC)
  │              └─→ verification-before-completion (Iron Law)
  │                   └─→ verification-loop (檢查清單) [參考]
  │                        └─→ sdd-archive (封存) [v3.0.0]
  │
  ├─→ systematic-debugging (除錯)
  ├─→ requesting-code-review (審查)
  └─→ security-review (ECC)
```

---

## 🚨 關鍵發現

### 發現 1：Superpowers 與 ECC 理念衝突

**Superpowers**：
- 絕對規則（Iron Laws）
- 零容忍違規
- "想跳過 = 理性化藉口"

**ECC**：
- 最佳實踐（Best Practices）
- 彈性調整
- "視專案需求調整"

**結論**：**兩者不可共存**，必須選擇一方或明確優先順序

### 發現 2：技能數量過多（32 個）

**現況**：
- 15 ECC + 14 Superpowers + 3 SDD = **32 個技能**
- AI 難以選擇正確的技能
- 使用者難以記住所有技能

**建議**：
- 合併重複功能（32 → 25 個）
- 建立清晰的層級結構
- AGENTS.md 明確技能優先順序

### 發現 3：SDD 技能定義不完整

**問題**：
- `sdd-propose`, `sdd-apply`, `sdd-archive` 目前只是 placeholder
- 沒有定義與其他技能的互動

**建議**：
- 在 Phase 2 實作前，先定義清楚互動關係
- 避免實作後再發現衝突

---

## ✅ 行動建議（優先順序）

### Phase 1A：立即清理（升級前）

**必須在 v3.0.0 升級前完成**：

1. **刪除 `tdd-workflow.md`**（ECC 版本）
   - 保留 `test-driven-development`（Superpowers）
   - 更新 AGENTS.md 引用

2. **明確 verification 分工**
   - 保留兩個，但在 AGENTS.md 明確說明用途

3. **更新 `.agents/skills/README.md`**
   - 移除 tdd-workflow 條目
   - 標註 Superpowers 優先順序

### Phase 1B：目錄重組（升級時）

**隨 v3.0.0 升級一起執行**：

4. **搬移 `.agents/` → `.scaffolding/agents/`**
   - 避免與專案 agents 混淆
   - 更新所有路徑引用

5. **建立技能優先順序檔案**
   - `.scaffolding/agents/PRIORITY.md`
   - 明確 Superpowers > SDD > ECC

### Phase 2：SDD 技能實作（實作時）

**Phase 2 開始前必須定義**：

6. **定義 SDD 技能與現有技能的互動**
   - sdd-propose 如何調用 brainstorming
   - sdd-apply 如何調用 test-driven-development
   - 寫成流程圖

7. **實作 3 個 SDD 技能**
   - 確保內部調用正確
   - 測試互動流程

### Phase 3：長期優化（Phase 3+）

8. **技能合併計畫**
   - 評估是否合併 verification 兩個版本
   - 統一文件風格

9. **使用者文件**
   - 建立「技能選擇指南」
   - 常見場景推薦技能組合

---

## 🤔 需要你的決策

**在我繼續修改 v3.0.0 計畫之前，請確認**：

### 決策 1：TDD 衝突處理

- [ ] **選項 A**：刪除 ECC `tdd-workflow`，只保留 Superpowers 版本
- [ ] **選項 B**：保留兩個，但 AGENTS.md 明確「Superpowers 優先」
- [ ] **選項 C**：合併成單一版本（以 Superpowers 為主）

### 決策 2：Verification 衝突處理

- [ ] **選項 A**：刪除 ECC `verification-loop`，只保留 Superpowers
- [ ] **選項 B**：保留兩個，明確分工（Iron Law + Checklist）
- [ ] **選項 C**：合併（Iron Law + 吸收 Checklist 內容）

### 決策 3：SDD 技能整合策略

- [ ] **選項 A**：sdd-propose 內部調用 brainstorming（我推薦）
- [ ] **選項 B**：sdd-propose 獨立運作，不調用其他技能
- [ ] **選項 C**：讓使用者手動選擇（brainstorming 或 sdd-propose）

### 決策 4：技能優先順序

- [ ] **選項 A**：Superpowers > SDD > ECC（我推薦）
- [ ] **選項 B**：使用者可以在 config.toml 設定優先順序
- [ ] **選項 C**：平等對待，由 AI 自己判斷

### 決策 5：目錄結構

- [ ] **確認**：同意將 `.agents/` 搬到 `.scaffolding/agents/`
- [ ] **調整**：有其他想法（請說明）

---

**請告訴我你的決策，我會據此調整 v3.0.0 計畫！** 🎯

---

## ✅ 決策結果（2026-03-27）

**決策者**: User + AI Assistant  
**參考**: ADR 0013 - Skills Architecture

---

### 決策 1：TDD 衝突處理 → **選項 A**

✅ **刪除 ECC `tdd-workflow`，只保留 Superpowers 版本**

**理由**：
- Superpowers 的 Iron Law 更嚴格，防止 AI 合理化跳過測試
- "違反字面 = 違反精神" 理念符合高品質開發
- ECC 版本太寬鬆，會讓 AI 妥協

**行動**：
```bash
rm .agents/skills/universal/tdd-workflow.md
```

---

### 決策 2：Verification 衝突處理 → **選項 B**

✅ **保留兩個，明確分工（Iron Law + Checklist）**

**分工**：
- `verification-before-completion` (Superpowers): **執行規則**
  - Iron Law: "沒在這個訊息執行命令 = 不算驗證"
  
- `verification-loop` (ECC): **檢查清單內容**
  - 列出要檢查什麼（build, test, lint, runtime）

**理由**：
- 兩者功能互補，不重複
- Iron Law 保證執行，Checklist 保證完整性

---

### 決策 3：SDD 技能整合策略 → **選項 A 變體（階段式整合）**

✅ **brainstorming → sdd-propose → sdd-apply 階段式流程**

**工作流程**：
```
Phase 1: 探索 (brainstorming)
  ↓ 產出: 非正式討論筆記
  
Phase 2: 正式化 (sdd-propose)
  ↓ 讀取 brainstorming 產出
  ↓ 產出: proposal.md + design.md + tasks.md
  
Phase 3: 實作 (sdd-apply)
  ↓ 強制調用: test-driven-development
  ↓ 產出: 實作 + 測試通過
```

**理由**：
- 清楚的階段區分
- 避免重複工作（sdd-propose 讀取 brainstorming）
- 保證 TDD（sdd-apply 強制調用）

---

### 決策 4：技能優先順序 → **選項 A**

✅ **Superpowers > SDD > ECC**

**優先順序系統**：
```
Priority 1: Superpowers (Iron Laws)     ← 最高
Priority 2: SDD Skills (Workflow)       ← 第二
Priority 3: ECC v2.0 (Enhanced)         ← 第三
Priority 4: Project Skills (Override)   ← 覆寫
```

**理由**：
- Superpowers Iron Laws 不可妥協
- SDD 定義工作流程
- ECC 提供實作細節

---

### 決策 5：目錄結構 → **確認**

✅ **同意將 `.agents/` 搬到 `.scaffolding/agents/`**

**新結構**：
```
.scaffolding/agents/    ← Template 技能
.agents/                ← 專案自己的 agents
```

**理由**：
- 清楚區分 "template" vs "專案"
- 避免專案自己的 agents 被 template 污染
- 符合「鷹架的都放鷹架裡」設計思維

---

### 核心策略：「Superpowers 嚴格度 × ECC 領域廣度」

**使用者建議**：
> 「可不可以嚴格程度以 Superpowers 為主，但是 ECC 的廣泛每個領域都要有這樣嚴格」

✅ **採納！每個 ECC 領域技能加上 Superpowers 風格的 Iron Laws**

**實施方式**：
```
ECC Skill v2.0 = 原有實作細節 + Superpowers Iron Laws
```

**範例**：
- backend-patterns v2.0 = 原有 patterns + Iron Laws (NO SYNC IN ASYNC, NO NAKED PROMISES)
- frontend-patterns v2.0 = 原有 patterns + Iron Laws (NO PROP DRILLING >2, NO INLINE HANDLERS)
- api-design v2.0 = 原有 design + Iron Laws (NO MISMATCHED HTTP METHODS, NO NAKED 500)

**改造優先順序**：
1. Phase 1A (高優先): backend, frontend, api-design, security, error-handling
2. Phase 1B (中優先): react-hooks, database, component, e2e, unit
3. Phase 2 (低優先): coding-standards

---

## 🚀 下一步行動

**Phase 1A 實施中**：

- [x] 撰寫 ADR 0013
- [x] 更新 SKILLS_CONFLICT_ANALYSIS.md（本文件）
- [ ] 建立 Iron Laws 改造模板
- [ ] 改造 5 個高優先度技能
- [ ] 更新 upgrade-to-v3.sh

**完整實施計畫**: 請參考 ADR 0013

---

**所有決策已記錄於**: `docs/adr/0013-skills-architecture-superpowers-strictness-ecc-coverage.md`
