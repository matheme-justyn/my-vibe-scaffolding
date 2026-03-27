# ADR 0013: Skills Architecture - Superpowers Strictness × ECC Domain Coverage

**狀態**: Accepted  
**日期**: 2026-03-27  
**決策者**: User + AI Assistant  
**相關 ADRs**: 
- ADR 0009: Reference Claude Code Architecture
- ADR 0012: Module System and Conditional Loading

---

## 背景脈絡

### 問題陳述

my-vibe-scaffolding 整合了兩套 AI 技能系統：

1. **Superpowers** (作者: Jesse Vincent @obra)
   - 位置: `~/.config/opencode/skills/superpowers/`
   - 14 個工作流程型技能
   - 風格: 嚴格規則（Iron Laws）
   - 特色: 零容忍違規、強制執行

2. **ECC (everything-claude-code)** (作者: affaan-m)
   - 位置: `.agents/skills/`
   - 15 個領域型技能（frontend, backend, testing）
   - 風格: 最佳實踐（Best Practices）
   - 特色: 彈性建議、視情況調整

### 發現的衝突

在 v3.0.0 規劃期間，發現以下問題：

#### 1. 嚴重功能衝突（TDD）

| 項目 | Superpowers | ECC |
|-----|-------------|-----|
| 技能名稱 | `test-driven-development` | `tdd-workflow` |
| 核心規則 | "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" | "Enforce TDD with 80%+ coverage" |
| 違規處理 | **刪除程式碼，重新開始** | 建議重寫 |
| 例外處理 | **無例外**（必須問人類） | 視專案調整 |

**問題**: AI 會選擇較寬鬆的 ECC 版本，違背 Superpowers 理念。

#### 2. 中度功能衝突（Verification）

| 項目 | Superpowers | ECC |
|-----|-------------|-----|
| 技能名稱 | `verification-before-completion` | `verification-loop` |
| 核心規則 | "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" | "Systematic verification checklist" |
| 執行時機 | **每次聲稱完成前**（在同一訊息執行命令） | 完成任務前、提交前 |
| 證據要求 | 必須在當前訊息執行 | 確認通過即可 |

**問題**: 規則嚴格度不同，AI 可能選擇較寬鬆版本。

#### 3. 領域覆蓋不完整

**Superpowers 強項**:
- 工作流程規則（brainstorming, systematic-debugging）
- 強制執行機制（Iron Laws）

**Superpowers 弱項**:
- 缺乏領域專業知識（frontend, backend, API design）
- 沒有針對特定技術棧的規則

**ECC 強項**:
- 廣泛的領域覆蓋（15 個領域）
- 具體的技術細節（React Hooks, Node.js patterns）

**ECC 弱項**:
- 規則不夠嚴格（建議而非強制）
- AI 容易找藉口跳過

### 目錄衝突問題

`.agents/` 目錄混用：
- Template 的技能（ECC skills）
- 專案自己的 agents（可能衝突）

**使用者反饋**: "鷹架的東西應該都放在鷹架裡"

---

## 決策

### 決策 1：Superpowers 作者更正

**決策**: 更正文件中對 Superpowers 作者的標註

**理由**:
- 真正作者: Jesse Vincent (@obra)
- 高見龍（Kao Chen-Long）只是介紹者，非作者
- 需要正確歸屬

**來源**:
- GitHub: https://github.com/obra/superpowers
- Blog: https://blog.fsck.com

---

### 決策 2：TDD 衝突處理

**決策**: 刪除 ECC `tdd-workflow`，只保留 Superpowers `test-driven-development`

**理由**:
1. Superpowers 的 Iron Law 更嚴格，防止 AI 合理化跳過測試
2. "違反字面 = 違反精神" 理念符合高品質開發
3. ECC 版本太寬鬆，會讓 AI 妥協

**影響**:
- 刪除: `.agents/skills/universal/tdd-workflow.md`
- 保留: `~/.config/opencode/skills/superpowers/test-driven-development/`
- 更新: AGENTS.md 技能引用

**替代方案（已拒絕）**:
- ❌ 保留兩個，標註優先順序 → AI 仍可能選錯
- ❌ 合併成單一版本 → 維護成本高

---

### 決策 3：Verification 衝突處理

**決策**: 保留兩個，明確分工

**分工**:
- `verification-before-completion` (Superpowers): **執行規則**
  - Iron Law: "沒在這個訊息執行命令 = 不算驗證"
  - 管「如何驗證」

- `verification-loop` (ECC): **檢查清單內容**
  - 列出要檢查的項目（build, test, lint, runtime）
  - 管「驗證什麼」

**理由**:
1. 兩者功能互補，不重複
2. Iron Law 保證執行，Checklist 保證完整性
3. 一起使用效果更好

**AGENTS.md 說明**:
```markdown
使用順序：
1. verification-before-completion - 強制執行驗證（Iron Law）
2. verification-loop - 參考檢查清單（build, test, lint）
```

---

### 決策 4：核心策略 - "Superpowers 嚴格度 × ECC 領域廣度"

**決策**: 保留 ECC 領域技能，但加上 Superpowers 風格的 Iron Laws

**核心理念**:
```
每個 ECC 領域技能 = 原有實作細節 + Superpowers Iron Laws
```

**實施方式**:

#### 階段 1: 定義 Iron Laws

為每個 ECC 技能新增「絕對不能做」的規則：

| ECC Skill | 新增的 Iron Laws |
|-----------|-----------------|
| **backend-patterns** | • NO SYNC CODE IN ASYNC PATHS<br>• NO NAKED PROMISES<br>• NO UNHANDLED ERRORS |
| **frontend-patterns** | • NO PROP DRILLING BEYOND 2 LEVELS<br>• NO INLINE HANDLERS IN LISTS<br>• NO UNKEYED LISTS |
| **api-design** | • NO MISMATCHED HTTP METHODS<br>• NO NAKED 500 ERRORS<br>• NO PAGINATION WITHOUT LINKS |
| **security-review** | • NO SECRETS IN CODE<br>• NO SQL STRING CONCAT<br>• NO EVAL EVER |
| **database-optimization** | • NO N+1 QUERIES<br>• NO SELECT *<br>• NO MISSING INDEXES ON FK |
| **error-handling** | • NO EMPTY CATCH BLOCKS<br>• NO SWALLOWED ERRORS<br>• NO STRING-ONLY ERRORS |
| **react-hooks** | • NO MISSING DEPS IN useEffect<br>• NO setState IN RENDER<br>• NO INFINITE LOOPS |
| **component-design** | • NO MIXED CONCERNS<br>• NO PROP TYPES MISMATCH<br>• NO SIDE EFFECTS IN RENDER |
| **e2e-testing** | • NO HARD-CODED WAITS<br>• NO TESTING IMPLEMENTATION DETAILS<br>• NO FLAKY TESTS TOLERATED |
| **unit-testing** | • NO TESTING IMPLEMENTATION<br>• NO EXCESSIVE MOCKING<br>• NO SHARED TEST STATE |
| **coding-standards** | • NO MAGIC NUMBERS<br>• NO FUNCTIONS >50 LINES<br>• NO NESTING >3 LEVELS |

#### 階段 2: 統一格式

所有改造後的技能遵循此結構：

```markdown
---
name: {skill-name}
version: 2.0.0
origin: ECC (everything-claude-code)
enhanced_with: Superpowers Iron Laws
---

# {Skill Title}

## Iron Laws (Superpowers 風格)

### 1. {RULE_NAME}

```{language}
// ❌ BAD
{bad_example}

// ✅ GOOD
{good_example}
```

**違反處理**: {what_to_do}

**不接受藉口**:
- ❌ "{excuse_1}"
- ❌ "{excuse_2}"

**強制執行**: {enforcement}

---

## Implementation Details (原 ECC 內容)

{原有的實作指導、範例、最佳實踐}
```

#### 階段 3: 改造優先順序

**Phase 1A (v3.0.0 升級前) - 高優先**:
1. backend-patterns
2. frontend-patterns
3. api-design
4. security-review
5. error-handling

**Phase 1B (v3.0.0 升級時) - 中優先**:
6. react-hooks
7. database-optimization
8. component-design
9. e2e-testing
10. unit-testing

**Phase 2 (v3.1.0+) - 低優先**:
11. coding-standards

**保持原樣（非技術規則）**:
- content-engine
- market-research

**理由**:
1. **保留優勢**: ECC 的領域廣度 + 技術細節
2. **加強執行**: Superpowers 的 Iron Laws 嚴格度
3. **避免妥協**: AI 不能在任何領域找藉口
4. **完整覆蓋**: 15 個領域 × 嚴格規則 = 全面品質保證

**替代方案（已拒絕）**:
- ❌ 只保留 Superpowers，刪除 ECC → 損失領域知識
- ❌ 保持 ECC 寬鬆風格 → AI 會找藉口妥協
- ❌ 分開維護兩套系統 → 使用者混淆

---

### 決策 5：SDD 技能整合策略

**決策**: 階段式整合 - brainstorming → sdd-propose → sdd-apply

**工作流程**:

```
Phase 1: 探索 (Brainstorming)
  ↓ 使用者: "我想新增功能 X"
  ↓ 技能: brainstorming
  ↓ 產出: 非正式討論筆記（自由格式）
  
Phase 2: 正式化 (SDD Propose)
  ↓ 使用者: "好，開始規劃"
  ↓ 技能: sdd-propose (讀取 brainstorming 產出)
  ↓ 產出: proposal.md + design.md + tasks.md (OpenSpec 格式)
  
Phase 3: 實作 (SDD Apply + TDD)
  ↓ 使用者: "開始實作"
  ↓ 技能: sdd-apply
  ↓ 內部強制調用: test-driven-development (Superpowers)
  ↓ 產出: 實作 + 測試通過
  
Phase 4: 驗證 (Verification)
  ↓ 自動觸發: verification-before-completion
  ↓ 參考清單: verification-loop
  ↓ 產出: 驗證報告
  
Phase 5: 封存 (SDD Archive)
  ↓ 使用者: "PR merged"
  ↓ 技能: sdd-archive
  ↓ 產出: 搬移到 archive/ + 更新 specs/
```

**關鍵設計**:
1. `sdd-propose` 讀取 `brainstorming` 產出（避免重複工作）
2. `sdd-apply` 強制調用 `test-driven-development`（不可跳過 TDD）
3. `verification-before-completion` 自動觸發（Iron Law）

**理由**:
- 清楚的階段區分（探索 → 正式化 → 實作 → 驗證 → 封存）
- 避免使用者混淆（何時用 brainstorming vs sdd-propose）
- 保證 TDD（sdd-apply 內部硬編碼調用）

---

### 決策 6：目錄結構調整

**決策**: 搬移 `.agents/` → `.scaffolding/agents/`

**新結構**:
```
my-vibe-scaffolding/
├── .agents/                    ← 保留給專案自己用（空的）
│   └── README.md              (說明：專案自己的 agents 放這裡)
│
├── .scaffolding/
│   ├── agents/                ← 所有 template 技能（搬到這裡）
│   │   ├── skills/
│   │   │   ├── frontend/
│   │   │   ├── backend/
│   │   │   ├── universal/
│   │   │   └── testing/
│   │   ├── agents/
│   │   ├── commands/
│   │   ├── bundles.yaml
│   │   └── workflows.yaml
│   └── openspec/              ← v3.0.0 新增
│
└── AGENTS.md                   ← 更新路徑引用
```

**技能載入順序**:
```
1. .agents/skills/                    (專案自己的，最高優先)
2. .scaffolding/agents/skills/        (Template 提供的)
3. ~/.config/opencode/skills/         (使用者安裝的 Superpowers)
```

**理由**:
1. 清楚區分 "template" vs "專案"
2. 避免專案自己的 agents 被 template 污染
3. 符合「鷹架的都放鷹架裡」設計思維

**遷移計畫**:
- 升級腳本自動搬移 `.agents/` → `.scaffolding/agents/`
- 保留空的 `.agents/` 給專案使用
- 更新所有 AGENTS.md 路徑引用

---

### 決策 7：技能優先順序

**決策**: 三層優先順序系統

```
Priority 1: Superpowers (Iron Laws)     ← 最高（強制規則）
Priority 2: SDD Skills (v3.0.0)         ← 第二（工作流程）
Priority 3: ECC Skills v2.0 (Enhanced)  ← 第三（實作細節）
Priority 4: User Project Skills         ← Override（專案覆寫）
```

**載入順序**:
```
AGENTS.md → Superpowers → SDD → ECC v2.0 → Project
           (Iron Laws)   (Workflow) (Details) (Override)
```

**衝突解決規則**:
```
IF superpowers 有 Iron Law：
    → 使用 Superpowers 版本（不可妥協）
ELSE IF SDD workflow 定義流程：
    → 使用 SDD 版本（工作流程）
ELSE IF ECC v2.0 有 Iron Law：
    → 使用 ECC v2.0 版本（領域規則）
ELSE：
    → 使用 ECC v2.0 Implementation Details（實作細節）
```

**AGENTS.md 明確聲明**:
```markdown
## Skills Priority System

**When same functionality exists in multiple skills:**

1. Superpowers Iron Laws - ALWAYS enforced (cannot be rationalized)
2. SDD Workflow - Process orchestration
3. ECC v2.0 Iron Laws - Domain-specific enforcement
4. ECC v2.0 Details - Implementation guidance
5. Project Skills - Override all above (explicit project decision)
```

---

## 結果

### 預期效益

**立即效益** (v3.0.0):
- ✅ 消除 TDD 衝突（刪除 ECC tdd-workflow）
- ✅ 明確 verification 分工
- ✅ 清楚的目錄結構（template vs project）
- ✅ 5 個高優先度技能加上 Iron Laws

**短期效益** (3 個月):
- ⚡ AI 不能在任何領域找藉口妥協
- 📈 程式碼品質提升（15 個領域 × 嚴格規則）
- 🎯 95% AI 任務完成率（目前 ~70%）
- 📉 -60% 返工次數（規則在前期就抓住錯誤）

**長期效益** (6 個月+):
- 🧠 團隊養成嚴格習慣（Iron Laws 成為直覺）
- 📚 完整的知識庫（15 領域 × Iron Laws + Details）
- 🚀 新成員快速上手（明確的規則）
- 💰 -50% 維護成本（規則防止技術債累積）

### 技能總數變化

**v2.x**:
- Superpowers: 14 技能
- ECC: 15 技能
- **總計**: 29 技能

**v3.0.0**:
- Superpowers: 14 技能（不變）
- ECC v2.0: 13 技能（刪除 tdd-workflow，保留 14 個）
- SDD: 3 技能（新增）
- **總計**: 30 技能

**技能品質**:
- v2.x: 14 Iron Laws + 15 Best Practices
- v3.0.0: 14 Iron Laws + 11 Iron Laws + 13 Details + 3 Workflows
- **Iron Laws 覆蓋率**: 48% → 83%

---

## 實施計畫

### Phase 1A: 立即清理（升級前）

**時間**: 2026-03-27

**任務**:
1. ✅ 撰寫 ADR 0013（本文件）
2. ✅ 更新 `docs/SKILLS_CONFLICT_ANALYSIS.md`（記錄決策）
3. ✅ 建立 Iron Laws 改造模板
4. ✅ 改造 5 個高優先度技能：
   - backend-patterns v2.0
   - frontend-patterns v2.0
   - api-design v2.0
   - security-review v2.0
   - error-handling v2.0
5. ✅ 更新 `.agents/skills/README.md`（移除 tdd-workflow 條目）

### Phase 1B: 目錄重組（升級時）

**時間**: v3.0.0 升級執行

**任務**:
6. 搬移 `.agents/` → `.scaffolding/agents/`
7. 建立空的 `.agents/` + README.md（說明用途）
8. 更新 AGENTS.md 所有路徑引用
9. 更新升級腳本 `upgrade-to-v3.sh`

### Phase 1C: SDD 技能實作（實作時）

**時間**: Phase 2 開始前

**任務**:
10. 實作 `sdd-propose`（讀取 brainstorming 產出）
11. 實作 `sdd-apply`（強制調用 test-driven-development）
12. 實作 `sdd-archive`（封存流程）
13. 測試完整工作流程

### Phase 2: 中優先度技能（v3.1.0）

**時間**: v3.0.0 release 後 1 個月

**任務**:
14. 改造 5 個中優先度技能：
    - react-hooks v2.0
    - database-optimization v2.0
    - component-design v2.0
    - e2e-testing v2.0
    - unit-testing v2.0

### Phase 3: 長期優化（v3.2.0+）

**時間**: v3.1.0 release 後 2 個月

**任務**:
15. 改造低優先度技能（coding-standards v2.0）
16. 使用者回饋收集與調整
17. Iron Laws 成效評估

---

## 替代方案

### 替代方案 1: 只保留 Superpowers，刪除所有 ECC

**優點**:
- ✅ 簡化技能系統（14 技能 vs 30 技能）
- ✅ 無衝突風險

**缺點**:
- ❌ 損失所有領域專業知識（frontend, backend, API, security）
- ❌ Superpowers 沒有涵蓋這些領域
- ❌ 需要從零開始建立領域技能

**為什麼拒絕**: 損失太大，Superpowers 只有工作流程，沒有領域知識。

---

### 替代方案 2: 保持 ECC 原樣（寬鬆風格）

**優點**:
- ✅ 不需要改造工作
- ✅ 維持 ECC 原始設計

**缺點**:
- ❌ AI 會選擇寬鬆版本，找藉口妥協
- ❌ 違背 Superpowers 的嚴格理念
- ❌ 程式碼品質無法保證

**為什麼拒絕**: 無法達成「每個領域都嚴格」的目標。

---

### 替代方案 3: 分開維護兩套系統

**優點**:
- ✅ 使用者可以選擇風格（嚴格 vs 寬鬆）
- ✅ 不需要改造 ECC

**缺點**:
- ❌ 使用者會混淆（該用哪套？）
- ❌ AI 會選擇寬鬆版本
- ❌ 雙倍維護成本

**為什麼拒絕**: 違背「統一標準」的原則，增加複雜度。

---

## 風險與緩解

### 風險 1: Iron Laws 過於嚴格，影響開發速度

**機率**: 中  
**影響**: 中

**緩解措施**:
1. 提供「例外處理」機制（必須明確記錄原因）
2. 可透過 `config.toml` 調整嚴格度：
   ```toml
   [skills]
   iron_laws_mode = "strict"  # strict | moderate | advisory
   ```
3. 收集使用者回饋，調整過於嚴苛的規則

---

### 風險 2: 改造 15 個技能工作量大

**機率**: 高  
**影響**: 低

**緩解措施**:
1. 分階段執行（Phase 1A: 5 個，Phase 1B: 5 個，Phase 2: 1 個）
2. 建立統一模板，減少重複工作
3. 高優先度優先（backend, frontend, api, security）

---

### 風險 3: 使用者不接受目錄結構改變

**機率**: 低  
**影響**: 中

**緩解措施**:
1. 升級腳本自動處理搬移
2. 提供回滾機制
3. MIGRATION_GUIDE 詳細說明理由

---

### 風險 4: SDD 技能與現有工作流程衝突

**機率**: 中  
**影響**: 中

**緩解措施**:
1. SDD 預設關閉（opt-in）
2. 提供三種模式：traditional | openspec | hybrid
3. 明確的技能調用順序（brainstorming → sdd-propose → sdd-apply）

---

## 參考資料

### 外部資源

1. **Superpowers**
   - GitHub: https://github.com/obra/superpowers
   - 作者: Jesse Vincent (@obra)
   - Blog: https://blog.fsck.com/2025/11/24/Superpowers-for-OpenCode/

2. **ECC (everything-claude-code)**
   - GitHub: https://github.com/affaan-m/everything-claude-code
   - 作者: affaan-m
   - 說明: 2025 Anthropic Hackathon 獲勝作品

3. **OpenSpec**
   - 網站: https://kaochenlong.com/openspec
   - 說明: 高見龍介紹的 Spec-Driven Development 系統

### 內部文件

1. **ADR 0009**: Reference Claude Code Architecture
   - 說明 ECC 整合決策

2. **ADR 0012**: Module System and Conditional Loading
   - 說明模組系統設計

3. **docs/SKILLS_CONFLICT_ANALYSIS.md**
   - 完整的技能衝突分析報告

4. **docs/MIGRATION_GUIDE_V3.md**
   - v3.0.0 升級指南

5. **docs/PRD-next-gen-sdd-integration.md**
   - v3.0.0 產品需求文件

---

## 修訂歷史

| 版本 | 日期 | 作者 | 變更內容 |
|-----|------|-----|---------|
| 1.0 | 2026-03-27 | User + AI | 初版：記錄所有 v3.0.0 技能架構決策 |

---

## 簽核

**提案者**: AI Assistant  
**審核者**: User  
**批准日期**: 2026-03-27  
**狀態**: ✅ Accepted

---

**此 ADR 記錄了 my-vibe-scaffolding v3.0.0 技能架構的完整設計決策，作為未來實作與維護的依據。**
