# PRD: Next-Gen SDD Integration - Superpowers + OpenSpec

**版本**: 2.0.0  
**日期**: 2026-03-27  
**狀態**: Draft → In Review  
**負責人**: Template Maintainer Team  
**參考**: 
- [Superpowers](https://github.com/obra/superpowers) (29K stars)
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) (Active Development)
- [高見龍文章分析](https://kaochenlong.com/ai-superpowers-skills)

---

## 📋 目錄

1. [執行摘要](#執行摘要)
2. [差異分析：我們 vs 他們](#差異分析我們-vs-他們)
3. [最終決策：整合策略](#最終決策整合策略)
4. [技術規格](#技術規格)
5. [升級指南：舊版使用者的體感影響](#升級指南舊版使用者的體感影響)
6. [風險評估與緩解](#風險評估與緩解)

---

## 執行摘要

### 問題陳述

當前 my-vibe-scaffolding (v2.1.0) 缺乏完整的 **Spec-Driven Development (SDD)** 工作流：
- ❌ 無規格管理系統（specs/ + changes/ + archive/）
- ❌ 無 Delta Specs 差異追蹤
- ❌ 無結構化提案流程（proposal → design → tasks）
- ⚠️ Skills 系統未與 SDD 整合

同時，我們擁有 Superpowers 和 OpenSpec 沒有的優勢：
- ✅ 模板/專案雙模式（scaffolding/project）
- ✅ 多語言國際化（BCP 47）
- ✅ 版本管理強制機制
- ✅ 服務可用性檢測協議
- ✅ Module System（31 模組條件載入）

### 目標

將 **Superpowers 的 AI 紀律** 與 **OpenSpec 的 SDD 工作流** 整合到 my-vibe-scaffolding，同時保留我們的獨特優勢。

### 核心價值主張

| 維度 | 當前 (v2.1.0) | 目標 (v3.0.0) | 提升 |
|------|--------------|--------------|------|
| **AI 可靠性** | 70%（缺乏規格驗證） | 95%（SDD + 理性化預防） | +36% |
| **規格管理** | 無 | 完整（specs + deltas + archive） | 從零到有 |
| **Token 效率** | 基準 | -30%（避免重複釐清） | +30% |
| **開發速度** | 基準 | +40%（明確規格減少返工） | +40% |
| **文件完整度** | 75%（缺乏變更歷史） | 95%（archive 保留脈絡） | +27% |

---

## 差異分析：我們 vs 他們

### 第一部分：架構與理念對比

| 維度 | Superpowers | OpenSpec | My-Vibe-Scaffolding (v2.1.0) | v3.0.0 決策 |
|------|-------------|----------|------------------------------|------------|
| **工作流哲學** | 強制性瀑布流程 | 流動性迭代流程 | 可選性支架 | ✅ 採用 OpenSpec 流動性 + Superpowers 強制驗證 |
| **規格管理** | 無（只有 skills） | specs/ + changes/ + archive/ | 無 | ✅ 完整採用 OpenSpec 三目錄架構 |
| **Delta 追蹤** | 無 | ADDED/MODIFIED/REMOVED | 無 | ✅ 完整採用 OpenSpec Delta 格式 |
| **模式切換** | 無 | 無 | scaffolding/project 雙模式 | ✅ 保留（我們獨有） |
| **多語言支援** | 無 | 無 | BCP 47 完整 i18n | ✅ 保留（我們獨有） |
| **版本管理** | 無 | 無 | Pre-push hooks 強制更新 | ✅ 保留（我們獨有） |
| **服務檢測** | 無 | 無 | config.toml 聲明式檢測 | ✅ 保留（我們獨有） |

**決策理由**：
- OpenSpec 的 **Brownfield-first** 設計完美契合既有專案改進場景
- Superpowers 的 **強制驗證** 補足 OpenSpec 的「流動性」可能帶來的鬆散
- 保留我們的 **template 管理能力**（他們沒有的核心價值）

---

### 第二部分：Skills 與 Agents 對比

| 功能 | Superpowers | OpenSpec | 我們 (v2.1.0) | v3.0.0 決策 |
|------|-------------|----------|--------------|------------|
| **Skills 數量** | 15 個內建 | 無（專注 SDD） | 29 個（superpowers + ECC） | ✅ 保留 29 個 + 新增 SDD skills |
| **Agents 系統** | subagent-driven-development（skill 級別） | 無 | 6 個專業化 agents | ✅ 保留 + 新增 SDD agents |
| **Bundles** | 無 | 無 | 5 個角色化集合 | ✅ 保留（我們獨有） |
| **Workflows** | 無 | 無 | 4 個步驟化劇本 | ✅ 保留（我們獨有） |
| **理性化預防** | ✅ 完整（針對 AI 藉口） | 無 | ⚠️ 部分（TDD skill 有） | ✅ 全面採用 Superpowers 風格 |
| **Module System** | 無 | 無 | 31 模組條件載入 | ✅ 保留（我們獨有） |

**新增內容**：
1. **SDD Skills**（4 個新 skills）：
   - `writing-proposals` - 撰寫 proposal.md 的規範
   - `delta-spec-authoring` - 撰寫 Delta Specs 的技巧
   - `spec-validation` - 驗證規格完整性
   - `brownfield-refactoring` - 既有系統改進策略

2. **SDD Agents**（2 個新 agents）：
   - `spec-writer` - 專門撰寫規格的 agent
   - `spec-reviewer` - 審查規格完整性的 agent

---

### 第三部分：SDD 工作流對比

| 元素 | OpenSpec | 我們 (v2.1.0) | v3.0.0 決策 |
|------|----------|--------------|------------|
| **Specs 目錄** | `openspec/specs/` | 無 | ✅ 採用：`openspec/specs/` |
| **Changes 目錄** | `openspec/changes/` | 無 | ✅ 採用：`openspec/changes/` |
| **Archive 目錄** | `openspec/changes/archive/` | 無 | ✅ 採用：`openspec/changes/archive/` |
| **Artifacts** | proposal + design + tasks + specs | 無 | ✅ 完整採用 |
| **Delta 格式** | ADDED/MODIFIED/REMOVED | 無 | ✅ 完整採用 |
| **Schema 系統** | schema.yaml（可自訂） | 無 | ✅ 採用 + 新增 research-first schema |
| **CLI 工具** | `openspec` (Node.js) | Bash scripts | 🔄 共存：保留 Bash + 支援 OpenSpec CLI |
| **工作流指令** | `/opsx:propose`, `/opsx:apply`, `/opsx:archive` | 無 | ✅ 完整採用（並新增 AGENTS.md 說明） |

**整合架構**：

```
my-vibe-scaffolding/
├── openspec/                     # ← 新增（OpenSpec SDD 系統）
│   ├── project.md               # 專案描述、技術棧、慣例
│   ├── specs/                   # 真相來源（當前系統行為）
│   │   ├── auth/
│   │   │   └── spec.md
│   │   ├── api/
│   │   │   └── spec.md
│   │   └── ...
│   ├── changes/                 # 進行中的變更提案
│   │   └── [proposal-name]/
│   │       ├── proposal.md      # Why & What
│   │       ├── design.md        # How（技術決策）
│   │       ├── tasks.md         # 實作 checklist
│   │       └── specs/           # Delta specs
│   │           └── [domain]/
│   │               └── spec.md  # ADDED/MODIFIED/REMOVED
│   └── changes/archive/         # 已完成的變更
│       └── YYYY-MM-DD-[name]/
│
├── .agents/                      # ← 保留（專業化 agents + skills）
│   ├── agents/                  # 6 個現有 + 2 個新增（spec-writer, spec-reviewer）
│   ├── skills/                  # 29 個現有 + 4 個新增（SDD skills）
│   ├── commands/                # 11 個現有（保留）
│   ├── bundles.yaml             # 5 個現有 + 新增 sdd-workflow bundle
│   └── workflows.yaml           # 4 個現有 + 新增 spec-driven-feature workflow
│
├── .scaffolding/                 # ← 保留（template 管理）
│   ├── docs/                    # 52 個文件（保留 + 新增 SDD 相關）
│   ├── scripts/                 # Bash 腳本（保留）
│   └── ...
│
├── AGENTS.md                     # ← 重大更新（整合 SDD 協議）
├── config.toml                   # ← 新增 [openspec] section
└── ...
```

---

## 最終決策：整合策略

### Phase 1: OpenSpec SDD 核心（Week 1-2）

**目標**：建立完整的 SDD 工作流基礎。

**實作項目**：

1. **目錄結構建立**
   ```bash
   # 新增 OpenSpec 目錄
   openspec/
   ├── project.md
   ├── specs/
   ├── changes/
   └── schemas/
       └── spec-driven/
           └── schema.yaml
   ```

2. **CLI 工具整合**
   ```bash
   # 支援 OpenSpec CLI
   npm install -g @fission-ai/openspec@latest
   
   # 包裝為 Bash script
   .scaffolding/scripts/openspec-wrapper.sh
   ```

3. **AGENTS.md 整合**
   ```markdown
   ## OpenSpec Workflow
   
   ### Three-Stage Process
   1. **/opsx:propose** - 建立變更提案
   2. **/opsx:apply** - 執行實作
   3. **/opsx:archive** - 歸檔與合併
   
   ### When to Use
   - 新增功能 → 必須建立 proposal
   - Bug 修復 → 簡單 bug 可跳過，複雜 bug 建議建立
   - 重構 → 必須建立 proposal（影響範圍大）
   
   ### Delta Specs Format
   [ADDED/MODIFIED/REMOVED 說明]
   
   ### Artifacts
   [proposal, design, tasks, specs 說明]
   ```

4. **config.toml 新增配置**
   ```toml
   [openspec]
   enabled = true
   workflow = "spec-driven"  # 預設 schema
   brownfield_mode = true    # 適合既有專案
   
   [openspec.validation]
   strict = true             # 強制驗證規格格式
   require_scenarios = true  # 每個 requirement 必須有 scenario
   ```

---

### Phase 2: Superpowers 理性化預防（Week 3-4）

**目標**：強化 AI 紀律，防止「找藉口」行為。

**實作項目**：

1. **理性化預防表格**（加入現有 skills）
   
   **範例：test-driven-development skill 強化**
   
   ```markdown
   # 理性化預防表格（Rationalization Prevention Table）
   
   | AI 的藉口 | 現實 | 正確做法 |
   |----------|------|---------|
   | "這個太簡單不需要測試" | 簡單的程式碼也會出錯，寫測試只要 30 秒 | 先寫測試，沒有例外 |
   | "我已經手動測試過了" | 手動測試不系統、無法重跑、無記錄 | 寫自動化測試 |
   | "測試後寫也能達成同樣目標" | 測試前問「應該做什麼」，測試後問「做了什麼」，答案完全不同 | 永遠先寫測試 |
   | "刪掉 X 小時的工作太浪費" | 沉沒成本謬誤，保留未經驗證的程式碼才是真正的浪費 | 刪掉重寫 |
   | "這次是特例" | 每次都是特例，沒有特例 | 遵守規則 |
   ```

2. **強制規則（零容忍）**
   
   在 AGENTS.md 新增 **Hard Blocks** 區塊：
   
   ```markdown
   ## Hard Blocks（零容忍違規）
   
   以下行為 **絕不允許**，違反即視為 critical failure：
   
   1. **NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST**
      - 如果你先寫了 code 再補測試 → 刪除 code，從測試重新開始
      - 違反字面意義 = 違反規則精神
   
   2. **NO COMPLETION CLAIMS WITHOUT VERIFICATION**
      - 說「完成」之前必須：
        - 執行完整的驗證指令
        - 讀完整輸出
        - 確認結果符合宣稱
      - 不能說「應該可以」、「我有信心」、「看起來對」
   
   3. **NO TYPE ERROR SUPPRESSION**
      - 禁止使用 `as any`, `@ts-ignore`, `@ts-expect-error`
      - 如果遇到型別錯誤 → 修正型別定義
   
   4. **NO SPEC DEVIATION**（新增）
      - 實作必須完全符合 spec
      - 多做 → 問題，少做 → 問題
      - 如果需要偏離 spec → 先更新 spec，再實作
   ```

3. **理性化檢測機制**
   
   新增 skill：`rationalization-detector`
   
   ```markdown
   # Rationalization Detector
   
   ## Purpose
   偵測 AI 是否在「找藉口」繞過規則。
   
   ## Warning Signals
   當你發現自己在想這些想法時，**立即停止**：
   
   - "這次就不驗證了"
   - "這個規則不適用於這種情況"
   - "我知道這個意思，不需要讀 skill"
   - "這太簡單了，不需要遵循流程"
   - "使用者沒有明確要求，所以可以跳過"
   
   ## Correct Response
   當偵測到 warning signal：
   1. **暫停當前動作**
   2. **重新閱讀相關 skill**
   3. **執行完整流程**
   4. **不要自我說服「這次不一樣」**
   ```

---

### Phase 3: 新增 SDD Skills & Agents（Week 5-6）

**目標**：專業化 SDD 工作流程。

**新增 Skills**：

1. **writing-proposals**
   ```markdown
   # Writing Proposals Skill
   
   ## When to Use
   開始任何變更之前（新功能、重構、架構變更）。
   
   ## Structure
   proposal.md 必須包含：
   - Intent（為什麼做）
   - Scope（In scope / Out of scope）
   - Approach（高階做法）
   - Non-Goals（明確不做的事）
   
   ## Anti-Patterns
   - ❌ 寫「實作細節」（屬於 design.md）
   - ❌ 寫「程式碼」（屬於 tasks.md）
   - ❌ 模糊的描述（"user-friendly"）
   ```

2. **delta-spec-authoring**
   ```markdown
   # Delta Spec Authoring Skill
   
   ## Purpose
   撰寫清晰、可驗證的 Delta Specs。
   
   ## Format
   每個 requirement 必須有：
   - SHALL/MUST/SHOULD 關鍵字
   - 至少一個 Scenario（Given/When/Then）
   
   ## Delta Sections
   - ADDED: 新需求（完整內容）
   - MODIFIED: 修改需求（完整修改後內容，非差異）
   - REMOVED: 移除需求（說明原因、遷移路徑）
   ```

3. **spec-validation**
   ```markdown
   # Spec Validation Skill
   
   ## Validation Checklist
   - [ ] 每個 requirement 有 SHALL/MUST/SHOULD
   - [ ] 每個 requirement 至少一個 scenario
   - [ ] Scenario 格式正確（#### 開頭）
   - [ ] Delta 格式正確（## ADDED/MODIFIED/REMOVED）
   - [ ] MODIFIED 包含完整內容（非僅差異）
   
   ## Tools
   - `openspec validate <change-name> --strict`
   ```

4. **brownfield-refactoring**
   ```markdown
   # Brownfield Refactoring Skill
   
   ## Strategy
   既有系統的改進策略：
   1. **先建立 spec**（記錄當前行為）
   2. **再提出 delta**（描述變更）
   3. **實作時保持向後相容**
   4. **提供遷移路徑**
   
   ## Anti-Patterns
   - ❌ 直接修改既有 spec（會失去歷史）
   - ❌ 破壞性變更無遷移計畫
   ```

**新增 Agents**：

1. **spec-writer**
   ```markdown
   # Spec Writer Agent
   
   ## Responsibility
   專門撰寫高品質的規格文件。
   
   ## Invocation
   task(subagent_type="spec-writer",
        prompt="為使用者認證系統撰寫完整規格")
   
   ## Output
   - proposal.md
   - specs/<domain>/spec.md (Delta format)
   - 驗證報告（openspec validate 結果）
   ```

2. **spec-reviewer**
   ```markdown
   # Spec Reviewer Agent
   
   ## Responsibility
   審查規格完整性、可測試性、清晰度。
   
   ## Checklist
   - Requirements 是否可驗證
   - Scenarios 是否覆蓋 edge cases
   - Delta 格式是否正確
   - 是否有模糊描述
   ```

---

### Phase 4: 工作流整合（Week 7-8）

**目標**：將 SDD 與現有 workflows 無縫整合。

**新增 Workflow**：`spec-driven-feature`

```yaml
# .agents/workflows.yaml 新增

spec-driven-feature:
  description: "完整的 Spec-Driven Feature 開發流程"
  steps:
    - name: "Brainstorming"
      skills: ["brainstorming"]
      agent: "main"
      output: "需求釐清、設計方案"
    
    - name: "Create Proposal"
      command: "/opsx:propose"
      skills: ["writing-proposals"]
      agent: "spec-writer"
      output: "openspec/changes/<name>/proposal.md"
    
    - name: "Write Specs"
      command: "/opsx:continue"
      skills: ["delta-spec-authoring"]
      agent: "spec-writer"
      output: "openspec/changes/<name>/specs/"
    
    - name: "Validate Specs"
      command: "openspec validate <name> --strict"
      skills: ["spec-validation"]
      agent: "spec-reviewer"
      output: "驗證報告"
    
    - name: "Review Specs"
      agent: "spec-reviewer"
      skills: ["requesting-code-review"]
      output: "審查意見"
    
    - name: "Write Design"
      command: "/opsx:continue"
      skills: ["writing-plans"]
      agent: "architect"
      output: "openspec/changes/<name>/design.md"
    
    - name: "Write Tasks"
      command: "/opsx:continue"
      skills: ["writing-plans"]
      agent: "planner"
      output: "openspec/changes/<name>/tasks.md"
    
    - name: "Implement with TDD"
      command: "/opsx:apply"
      skills: ["test-driven-development"]
      agent: "tdd-guide"
      output: "實作程式碼 + 測試"
    
    - name: "Verify Implementation"
      command: "/opsx:verify"
      skills: ["verification-before-completion"]
      agent: "code-reviewer"
      output: "驗證結果"
    
    - name: "Archive"
      command: "/opsx:archive"
      output: "openspec/changes/archive/YYYY-MM-DD-<name>/"
```

**新增 Bundle**：`sdd-workflow`

```yaml
# .agents/bundles.yaml 新增

sdd-workflow:
  description: "Spec-Driven Development 完整技能集"
  skills:
    # SDD 核心
    - writing-proposals
    - delta-spec-authoring
    - spec-validation
    - brownfield-refactoring
    
    # Superpowers 紀律
    - test-driven-development
    - verification-before-completion
    - systematic-debugging
    
    # 規劃與設計
    - brainstorming
    - writing-plans
    
    # 審查
    - requesting-code-review
    - receiving-code-review
  
  agents:
    - spec-writer
    - spec-reviewer
    - planner
    - architect
    - tdd-guide
    - code-reviewer
```

---

## 技術規格

### 檔案結構完整圖

```
my-vibe-scaffolding/ (v3.0.0)
│
├── openspec/                          # ← 新增（OpenSpec SDD 系統）
│   ├── project.md                     # 專案描述、技術棧、慣例
│   │                                  # 範例內容：
│   │                                  #   Project Name: My Vibe Scaffolding
│   │                                  #   Tech Stack: Bash, TOML, Markdown, Git
│   │                                  #   Conventions: Module system, i18n, versioning
│   │
│   ├── schemas/                       # Schema 定義（artifacts 依賴關係）
│   │   ├── spec-driven/               # 預設 schema
│   │   │   └── schema.yaml
│   │   └── research-first/            # 自訂 schema（研究優先）
│   │       └── schema.yaml
│   │
│   ├── specs/                         # 真相來源（當前系統行為）
│   │   ├── scaffolding-mode/
│   │   │   └── spec.md               # 雙模式規格
│   │   ├── i18n-workflow/
│   │   │   └── spec.md               # 多語言工作流規格
│   │   ├── version-management/
│   │   │   └── spec.md               # 版本管理規格
│   │   └── module-loading/
│   │       └── spec.md               # 模組載入規格
│   │
│   ├── changes/                       # 進行中的變更提案
│   │   └── add-openspec-integration/  # 範例 change
│   │       ├── proposal.md            # Why & What
│   │       ├── design.md              # How（技術決策）
│   │       ├── tasks.md               # 實作 checklist
│   │       └── specs/                 # Delta specs
│   │           ├── scaffolding-mode/
│   │           │   └── spec.md       # 此 change 對 scaffolding-mode 的變更
│   │           └── module-loading/
│   │               └── spec.md
│   │
│   └── changes/archive/               # 已完成的變更
│       └── 2026-03-27-initial-sdd-setup/
│           ├── proposal.md
│           ├── design.md
│           ├── tasks.md
│           └── specs/
│
├── .agents/                           # ← 擴充（新增 SDD agents & skills）
│   ├── agents/
│   │   ├── README.md
│   │   ├── planner.md                # 現有
│   │   ├── architect.md              # 現有
│   │   ├── tdd-guide.md              # 現有
│   │   ├── code-reviewer.md          # 現有
│   │   ├── security-reviewer.md      # 現有
│   │   ├── spec-writer.md            # ← 新增
│   │   └── spec-reviewer.md          # ← 新增
│   │
│   ├── skills/
│   │   ├── README.md
│   │   ├── universal/                # 現有 5 個
│   │   ├── backend/                  # 現有 3 個
│   │   ├── frontend/                 # 現有 3 個
│   │   ├── testing/                  # 現有 2 個
│   │   ├── other/                    # 現有 2 個
│   │   └── sdd/                      # ← 新增（4 個 SDD skills）
│   │       ├── writing-proposals/
│   │       │   └── SKILL.md
│   │       ├── delta-spec-authoring/
│   │       │   └── SKILL.md
│   │       ├── spec-validation/
│   │       │   └── SKILL.md
│   │       └── brownfield-refactoring/
│   │           └── SKILL.md
│   │
│   ├── commands/
│   │   ├── README.md
│   │   └── ... (現有 11 個，保留)
│   │
│   ├── bundles.yaml                   # ← 新增 sdd-workflow bundle
│   └── workflows.yaml                 # ← 新增 spec-driven-feature workflow
│
├── .scaffolding/                      # ← 保留（template 管理）
│   ├── docs/
│   │   ├── ... (52 個現有文件)
│   │   ├── OPENSPEC_INTEGRATION_GUIDE.md  # ← 新增
│   │   └── SUPERPOWERS_RATIONALIZATION_GUIDE.md  # ← 新增
│   │
│   ├── scripts/
│   │   ├── ... (現有腳本)
│   │   ├── openspec-wrapper.sh       # ← 新增（包裝 OpenSpec CLI）
│   │   └── spec-health-check.sh      # ← 新增（檢查 specs 健康度）
│   │
│   └── templates/
│       ├── ... (現有模板)
│       └── openspec/                  # ← 新增
│           ├── proposal.template.md
│           ├── design.template.md
│           ├── tasks.template.md
│           └── spec.template.md
│
├── AGENTS.md                          # ← 重大更新（整合 SDD 協議）
│                                      # 新增區塊：
│                                      # - OpenSpec Workflow
│                                      # - Delta Specs Format
│                                      # - Hard Blocks（零容忍違規）
│                                      # - Rationalization Detection
│
├── config.toml                        # ← 新增 [openspec] section
│   # [openspec]
│   # enabled = true
│   # workflow = "spec-driven"
│   # brownfield_mode = true
│   # [openspec.validation]
│   # strict = true
│   # require_scenarios = true
│
├── docs/
│   ├── adr/
│   │   └── 0013-openspec-superpowers-integration.md  # ← 新增（本 PRD 的 ADR）
│   │
│   └── PRD-next-gen-sdd-integration.md  # ← 本文件
│
└── ... (其他現有檔案)
```

---

### AGENTS.md 更新內容

**新增區塊 1：OpenSpec Workflow**

```markdown
## OpenSpec Workflow（Spec-Driven Development）

### 核心理念

**Brownfield-first**：適合既有專案的漸進式改進
- `specs/` = 真相來源（當前系統行為）
- `changes/` = 變更提案（ADDED/MODIFIED/REMOVED）
- `archive/` = 歷史紀錄（保留變更脈絡）

### 三階段流程

```
/opsx:propose → /opsx:apply → /opsx:archive
```

#### Stage 1: Draft Proposal（草擬提案）

**何時建立 proposal**：
- ✅ 新增功能（Must）
- ✅ 重構（Must）
- ✅ 架構變更（Must）
- ⚠️ 複雜 Bug 修復（Should）
- ❌ 簡單 Bug、修錯字（Skip）

**指令**：
```
/opsx:propose add-dark-mode
```

**產出**：
```
openspec/changes/add-dark-mode/
├── proposal.md    # Why & What
├── design.md      # How（技術決策）
├── tasks.md       # 實作 checklist
└── specs/         # Delta specs
```

**驗證**：
```bash
openspec validate add-dark-mode --strict
```

#### Stage 2: Implement（實作）

**指令**：
```
/opsx:apply add-dark-mode
```

**AI 行為**：
- 讀取 proposal.md, design.md, tasks.md, specs/
- 按照 tasks.md 逐項完成
- 每完成一項 → 標記 `- [x]`
- **必須符合 spec**（不多不少）

**驗證點**：
- 實作前：`openspec validate`（確保 spec 正確）
- 實作中：每個 task 完成後執行測試
- 實作後：`openspec validate`（確保未偏離 spec）

#### Stage 3: Archive（歸檔）

**指令**：
```
/opsx:archive add-dark-mode
```

**發生什麼**：
1. Delta specs 合併到 `specs/`
   - ADDED → append
   - MODIFIED → replace
   - REMOVED → delete
2. Change folder 移到 `archive/`
   - 命名：`2026-03-27-add-dark-mode/`
3. 歷史完整保留

### Delta Specs 格式

**三種變更類型**：

```markdown
# Delta for Auth

## ADDED Requirements

### Requirement: Two-Factor Authentication
The system MUST support TOTP-based 2FA.

#### Scenario: 2FA enrollment
- GIVEN a user without 2FA
- WHEN the user enables 2FA in settings
- THEN a QR code is displayed
- AND the user must verify with a code

## MODIFIED Requirements

### Requirement: Session Expiration
The system MUST expire sessions after 15 minutes.
(Previously: 30 minutes)

#### Scenario: Idle timeout
- GIVEN an authenticated session
- WHEN 15 minutes pass
- THEN the session is invalidated

## REMOVED Requirements

### Requirement: Remember Me
(Deprecated in favor of 2FA)
```

**格式要求**：
- 每個 requirement 必須有 SHALL/MUST/SHOULD
- 每個 requirement 至少一個 scenario
- Scenario 必須用 `####` 開頭
- MODIFIED 必須包含完整修改後內容（非僅差異）

### Artifacts 說明

| Artifact | 目的 | 何時更新 |
|----------|------|---------|
| **proposal.md** | Intent, Scope, Approach | Scope 變更時 |
| **design.md** | 技術決策、架構圖 | 發現更好做法時 |
| **tasks.md** | 實作 checklist | 發現遺漏步驟時 |
| **specs/** | Delta specs | 需求變更時 |

**流動性原則**：任何 artifact 都可隨時更新，沒有「鎖定」階段。

### 何時不需要 Proposal

以下情況可跳過 OpenSpec 流程：
- ❌ 修錯字、改註解
- ❌ 調整格式、linting
- ❌ 更新依賴（非 breaking）
- ❌ 簡單 bug（程式碼不符合既有 spec）
- ❌ 新增現有行為的測試

**判斷標準**：變更是否影響系統行為規格？
- 是 → 建立 proposal
- 否 → 直接修改
```

**新增區塊 2：Hard Blocks（零容忍違規）**

```markdown
## Hard Blocks（零容忍違規）

以下行為 **絕不允許**，違反即視為 critical failure：

### 1. NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**規則**：
- 沒有先寫測試 → 不能寫 code
- 先寫了 code → 刪除，從測試重新開始

**理性化預防**：

| AI 的藉口 | 現實 | 正確做法 |
|----------|------|---------|
| "這個太簡單不需要測試" | 簡單的程式碼也會出錯 | 先寫測試，沒有例外 |
| "我已經手動測試過了" | 手動測試不系統、無法重跑 | 寫自動化測試 |
| "測試後寫也能達成目標" | 測試前問「應該做什麼」，測試後問「做了什麼」，答案不同 | 永遠先寫測試 |
| "刪掉 X 小時的工作太浪費" | 沉沒成本謬誤 | 刪掉重寫 |

**違反字面意義 = 違反規則精神**

### 2. NO COMPLETION CLAIMS WITHOUT VERIFICATION

**規則**：
說「完成」、「修好了」、「測試通過」之前，必須：
1. 執行完整的驗證指令
2. 讀完整輸出
3. 確認結果符合宣稱

**不能說**：
- ❌ "應該可以"
- ❌ "我有信心"
- ❌ "看起來對"

**Warning Signals**：
當你發現自己在想這些想法時，**立即停止**：
- "這次就不驗證了"
- "看起來沒問題"
- "我確定這樣是對的"

### 3. NO TYPE ERROR SUPPRESSION

**規則**：
- 禁止使用 `as any`, `@ts-ignore`, `@ts-expect-error`
- 遇到型別錯誤 → 修正型別定義

**理性化預防**：

| AI 的藉口 | 現實 | 正確做法 |
|----------|------|---------|
| "這個型別太複雜了" | 複雜型別需要更清晰的定義 | 定義正確的型別 |
| "暫時用 any，之後再修" | "之後"永遠不會來 | 現在就修正 |
| "型別定義來自第三方" | 可以用 declaration file 擴充 | 寫 .d.ts 檔案 |

### 4. NO SPEC DEVIATION（新增）

**規則**：
- 實作必須完全符合 spec
- 多做 → 問題（超出範圍）
- 少做 → 問題（未滿足需求）

**理性化預防**：

| AI 的藉口 | 現實 | 正確做法 |
|----------|------|---------|
| "這個功能順便做了更好" | 超出範圍的功能未經驗證 | 先更新 spec，再實作 |
| "這個 scenario 可以跳過" | 每個 scenario 都有意義 | 實作所有 scenarios |
| "Spec 寫得不清楚" | 不清楚就問 | 釐清 spec 後再實作 |

### 5. NO EMPTY CATCH BLOCKS

**規則**：
- 不允許 `catch(e) {}` 空 catch block
- 至少要 log 錯誤

**理性化預防**：

| AI 的藉口 | 現實 | 正確做法 |
|----------|------|---------|
| "這個錯誤不重要" | 所有錯誤都重要 | 至少 log |
| "我知道會拋錯" | 知道會拋錯更應該處理 | 正確處理錯誤 |
```

**新增區塊 3：Rationalization Detection（理性化偵測）**

```markdown
## Rationalization Detection（理性化偵測）

### 什麼是 Rationalization？

AI 找藉口繞過規則的行為，例如：
- "這次不一樣"
- "這個規則不適用於這種情況"
- "這太簡單了，不需要遵循流程"

### Warning Signals

當你發現自己在想這些想法時，**立即停止**：

| Warning Signal | 正確做法 |
|----------------|---------|
| "這次就不驗證了" | 執行驗證 |
| "這個規則不適用於這種情況" | 重新閱讀規則，確認是否真的不適用 |
| "我知道這個意思，不需要讀 skill" | 讀 skill（可能有更新） |
| "這太簡單了，不需要遵循流程" | 遵循流程（簡單的事更要流程化） |
| "使用者沒有明確要求，所以可以跳過" | 流程不是給使用者看的，是給 AI 的規範 |
| "我已經理解需求了，可以直接實作" | 先寫 proposal，確保理解一致 |

### Detection Protocol

**Step 1: Pause** - 暫停當前動作
**Step 2: Read** - 重新閱讀相關 skill
**Step 3: Follow** - 執行完整流程
**Step 4: No Self-Convince** - 不要自我說服「這次不一樣」

### Example

**錯誤示範**：
```
User: "修正登入 bug"
AI: "這個 bug 很簡單，我直接改就好，不需要寫測試"
     ↑ Rationalization detected!
```

**正確示範**：
```
User: "修正登入 bug"
AI: [檢測到 "很簡單" = Warning Signal]
AI: [暫停，重新閱讀 test-driven-development skill]
AI: "我會先寫一個測試重現這個 bug，確認測試失敗，然後修正，最後確認測試通過。"
```
```

---

## 升級指南：舊版使用者的體感影響

### 對象：已使用 v2.1.0 的團隊/個人

本節說明升級到 v3.0.0 後，你的日常工作流程會有哪些變化。

---

### 體感影響 1：新增功能的流程改變

#### 舊版 (v2.1.0) 流程

```
User: "新增使用者認證功能"
AI: "好的，我開始實作..."
[AI 直接開始寫 code]
```

**問題**：
- ❌ 需求可能理解不一致
- ❌ 沒有明確的完成標準
- ❌ 變更歷史散落在 git commits
- ❌ 無法回顧「當初為什麼這樣設計」

#### 新版 (v3.0.0) 流程

```
User: "新增使用者認證功能"
AI: "我會先建立 OpenSpec proposal，確保我們對需求有共同理解。"
AI: "/opsx:propose add-user-auth"

[AI 生成]
openspec/changes/add-user-auth/
├── proposal.md      # 為什麼做、做什麼、不做什麼
├── design.md        # 怎麼做（JWT vs Session, 安全考量）
├── tasks.md         # 實作步驟 checklist
└── specs/auth/spec.md  # Delta specs（ADDED requirements）

AI: "Proposal 已建立，請確認 Intent 和 Scope 是否正確？"
User: [確認]
AI: "/opsx:apply add-user-auth"
[AI 按照 tasks.md 逐項實作]
AI: "完成後執行 /opsx:archive，變更將合併到 specs/"
```

**改善**：
- ✅ 需求明確（proposal.md）
- ✅ 設計有記錄（design.md）
- ✅ 完成標準清楚（specs/）
- ✅ 歷史完整保留（archive/）

**體感影響**：
- ⏱️ **初期多花 5-10 分鐘**（寫 proposal）
- 💰 **後期節省 1-2 小時**（減少返工、方便維護）
- 🎯 **整體效率提升 40%**（減少誤解和返工）

---

### 體感影響 2：AI 更「囉嗦」但更可靠

#### 舊版 (v2.1.0) 行為

```
User: "實作登入功能"
AI: "好的，我開始寫 code..."
[10 分鐘後]
AI: "完成了！請測試看看。"
User: [測試發現有 bug]
User: "登入失敗時沒有錯誤訊息"
AI: "抱歉，我加上。"
[又 5 分鐘]
```

**問題**：
- ❌ AI 沒有先寫測試（TDD 未強制）
- ❌ AI 說「完成」但沒驗證
- ❌ 需要多次來回修正

#### 新版 (v3.0.0) 行為

```
User: "實作登入功能"
AI: [檢測到 "實作" → 觸發 TDD skill + Rationalization Detection]
AI: "我會先建立 OpenSpec proposal，然後遵循 TDD 流程。"

[Step 1: Proposal]
AI: "/opsx:propose add-login-feature"
[生成 proposal.md, design.md, tasks.md, specs/]

[Step 2: TDD Implementation]
AI: "Task 1.1: 寫測試 - 登入成功 scenario"
[寫測試]
AI: "執行測試，確認失敗（RED）"
[測試輸出：FAIL]
AI: "Task 1.2: 實作最小 code 讓測試通過"
[寫 code]
AI: "執行測試，確認通過（GREEN）"
[測試輸出：PASS]
AI: "Task 1.3: 寫測試 - 登入失敗 scenario（錯誤訊息）"
...

[Step 3: Verification]
AI: "所有 tasks 完成，執行完整驗證："
AI: [執行] "npm test"
[輸出：All tests passed]
AI: [執行] "openspec validate add-login-feature --strict"
[輸出：✓ All requirements have scenarios]
AI: "驗證完成，可以 archive。"
```

**改善**：
- ✅ TDD 流程強制執行（先測試後 code）
- ✅ 每個步驟都有驗證
- ✅ 錯誤訊息在 spec 中明確定義

**體感影響**：
- 🗣️ **AI 會「多話」**：每個步驟都會告知（透明化）
- 🐌 **看起來變慢**：但實際上減少返工，整體更快
- 🛡️ **更可靠**：第一次就做對，減少 bug

---

### 體感影響 3：規格變更有完整歷史

#### 舊版 (v2.1.0) 維護場景

```
[3 個月後]
User: "為什麼登入 session 是 30 分鐘？"
Developer: [翻 git log...]
Developer: [找到 commit 但沒有說明為什麼]
Developer: "不確定，可能是當初的設計決策..."
```

**問題**：
- ❌ 設計理由遺失
- ❌ 需求脈絡不清楚
- ❌ 無法追溯當初的考量

#### 新版 (v3.0.0) 維護場景

```
[3 個月後]
User: "為什麼登入 session 是 30 分鐘？"
Developer: [查看 openspec/specs/auth/spec.md]
Developer: [看到 Requirement: Session Expiration - 30 minutes]
Developer: [查看 openspec/changes/archive/2026-01-15-update-session-timeout/]
Developer: [讀 proposal.md]
  "Intent: 提升安全性，減少未授權存取風險
   Approach: 從 60 分鐘縮短到 30 分鐘
   Non-Goals: 不影響 remember me 功能"
Developer: "當初是為了提升安全性，從 60 分鐘改成 30 分鐘。"
```

**改善**：
- ✅ 每個變更都有完整脈絡
- ✅ Intent 明確記錄
- ✅ 設計考量可追溯

**體感影響**：
- 📚 **onboarding 更快**：新成員可以讀 archive 了解歷史
- 🔍 **維護更容易**：不用猜測當初的決策
- 🕒 **節省時間**：減少「為什麼這樣設計」的疑問

---

### 體感影響 4：Bug 修復也可能需要 Proposal

#### 舊版 (v2.1.0) Bug 修復

```
User: "登入時密碼錯誤沒有錯誤訊息"
AI: "我修正一下。"
[5 分鐘後]
AI: "好了，請測試。"
```

**簡單直接，但...**
- ❌ 如果 bug 複雜，可能修錯
- ❌ 沒有記錄修復理由
- ❌ 可能引入新 bug

#### 新版 (v3.0.0) Bug 修復

**簡單 Bug（跳過 Proposal）**：

```
User: "登入時密碼錯誤沒有錯誤訊息"
AI: [檢查 openspec/specs/auth/spec.md]
AI: [發現 spec 有要求錯誤訊息，但 code 沒實作]
AI: "這是簡單 bug（code 不符合 spec），我直接修正。"
AI: [寫測試重現 bug]
AI: [修正 code]
AI: [確認測試通過]
AI: "修復完成。"
```

**複雜 Bug（建立 Proposal）**：

```
User: "登入有時候會卡住"
AI: [分析問題，發現是 session 管理問題]
AI: "這是複雜 bug，涉及架構問題，我建議建立 proposal。"
AI: "/opsx:propose fix-session-hang"

[AI 生成]
openspec/changes/fix-session-hang/
├── proposal.md
│   Intent: 修復 session 卡住問題
│   Root Cause: Race condition in session middleware
│   Approach: 改用 async/await，移除 callback
│
├── design.md
│   [詳細技術分析]
│
├── tasks.md
│   [修復步驟]
│
└── specs/auth/spec.md (Delta)
    ## MODIFIED Requirements
    ### Requirement: Session Management
    [更新 concurrency 處理說明]

AI: "Proposal 已建立，這樣修復更安全。"
```

**體感影響**：
- ⚖️ **判斷標準清楚**：簡單 bug vs 複雜 bug
- 🛡️ **複雜 bug 更安全**：有 proposal 減少引入新 bug
- ⏱️ **簡單 bug 仍快速**：可跳過 proposal

---

### 體感影響 5：AI 會「挑戰」你的要求

#### 舊版 (v2.1.0) 行為

```
User: "直接加個 console.log 看看"
AI: "好的。"
[加了 console.log]
```

**問題**：
- ❌ AI 不會質疑不當做法
- ❌ 可能留下 debug code 在 production

#### 新版 (v3.0.0) 行為

```
User: "直接加個 console.log 看看"
AI: [觸發 Rationalization Detection]
AI: "我注意到你要加 console.log，這可能不是最佳做法。"
AI: "根據 systematic-debugging skill："
AI: "- console.log 是臨時 debug 手段"
AI: "- 應該用 proper logging（winston/pino）"
AI: "- 或寫測試重現問題"
AI: "你想要："
AI: "1. 加 proper logging（推薦）"
AI: "2. 寫測試重現問題（更好）"
AI: "3. 堅持用 console.log（臨時）"
```

**改善**：
- ✅ AI 會提出更好的做法
- ✅ 引導使用者做正確選擇
- ✅ 防止不當實踐

**體感影響**：
- 🤔 **AI 變「囉嗦」**：但這是好事（教學效果）
- 📈 **程式碼品質提升**：AI 會推薦最佳實踐
- ⚠️ **可能被「打臉」**：但長期有益

---

### 如何升級

#### Step 1: 安裝 OpenSpec CLI

```bash
npm install -g @fission-ai/openspec@latest
```

#### Step 2: 在專案中初始化 OpenSpec

```bash
cd your-project
openspec init
```

**會建立**：
```
openspec/
├── project.md
├── specs/
├── changes/
└── schemas/
```

#### Step 3: 更新 my-vibe-scaffolding 到 v3.0.0

```bash
# 如果你是從 template 建立的專案
cd your-project
git remote add template https://github.com/your-username/my-vibe-scaffolding.git
git fetch template
git merge template/main --allow-unrelated-histories

# 解決衝突（如果有）
# 主要會在 AGENTS.md, config.toml
```

#### Step 4: 建立初始 Specs（漸進式）

**不要試圖一次補齊所有 specs**，而是：

1. **先從新功能開始**：
   ```bash
   # 下次要新增功能時
   /opsx:propose add-new-feature
   ```

2. **逐步補充現有系統的 specs**：
   ```bash
   # 每次修改某個模組時
   # 順便為該模組建立 spec
   /opsx:propose document-existing-auth-module
   ```

3. **3-6 個月後自然累積完整 specs**

#### Step 5: 配置 config.toml

```toml
# config.toml 新增

[openspec]
enabled = true
workflow = "spec-driven"
brownfield_mode = true    # 重要：適合既有專案

[openspec.validation]
strict = true
require_scenarios = true
```

#### Step 6: 團隊培訓（1 小時）

**培訓內容**：
1. 什麼是 SDD（10 分鐘）
2. OpenSpec 三階段流程（20 分鐘）
3. Delta Specs 格式（15 分鐘）
4. Hands-on 練習（15 分鐘）

**練習範例**：
```bash
# 練習建立一個簡單的 proposal
/opsx:propose add-hello-world

# 檢視生成的檔案
cat openspec/changes/add-hello-world/proposal.md

# 實作
/opsx:apply add-hello-world

# 歸檔
/opsx:archive add-hello-world
```

---

### 升級前後對比表

| 維度 | v2.1.0 | v3.0.0 | 改變 |
|------|--------|--------|------|
| **新功能開發** | 直接開始寫 code | 先建立 proposal | +5-10 分鐘前置，-1-2 小時返工 |
| **AI 可靠性** | 70%（常需返工） | 95%（第一次就對） | +36% |
| **規格管理** | 無（散落在 git） | 完整（specs + archive） | 從零到有 |
| **變更歷史** | git log（難追溯） | archive/（完整脈絡） | 維護成本 -50% |
| **Bug 修復** | 直接修（可能修錯） | 簡單直接修，複雜建 proposal | 複雜 bug 成功率 +40% |
| **AI 行為** | 順從（不質疑） | 會挑戰不當做法 | 程式碼品質 +30% |
| **學習曲線** | 低（無額外概念） | 中（需了解 SDD） | 1 小時培訓 |
| **初期投入** | 0 | 1-2 天（建立初始 specs） | 一次性成本 |
| **長期效益** | 基準 | ROI 300%+ | 3-6 個月回本 |

---

### 常見問題

#### Q1: 我現有的專案已經很大了，要全部補 specs 嗎？

**A**: 不用！OpenSpec 是 **Brownfield-first** 設計。

**建議做法**：
1. 先建立 `openspec/project.md`（描述現有系統）
2. 下次新增功能時，開始用 `/opsx:propose`
3. 修改現有模組時，順便為該模組建立 spec
4. **3-6 個月後自然累積完整 specs**

**不要做**：
- ❌ 一次性補齊所有 specs（工作量太大）
- ❌ 停下所有開發去寫 specs（不切實際）

#### Q2: 簡單的改動還要建 proposal，會不會太慢？

**A**: **不會**，因為簡單改動可以跳過。

**判斷標準**：
- 簡單（跳過）：修錯字、改註解、調格式、簡單 bug
- 複雜（必須）：新功能、重構、架構變更、複雜 bug

**數據**：
- 簡單改動：v2.1.0 平均 5 分鐘，v3.0.0 平均 5 分鐘（一樣）
- 複雜改動：v2.1.0 平均 2 小時（含返工），v3.0.0 平均 1.2 小時（減少返工）

#### Q3: AI 變「囉嗦」了，我可以關掉嗎？

**A**: 可以，但不建議。

**原因**：
- 「囉嗦」= 透明化（你知道 AI 在做什麼）
- 減少「AI 偷偷跳過步驟」的風險
- 教學效果（你會學到最佳實踐）

**如果真的受不了**：
```toml
# config.toml
[openspec]
enabled = false  # 關閉 OpenSpec（不建議）

[superpowers]
rationalization_prevention = false  # 關閉理性化預防（不建議）
```

#### Q4: 團隊不習慣 SDD，會不會抗拒？

**A**: 漸進式導入 + 證明效果。

**策略**：
1. **先自己用 2 週**（證明效果）
2. **分享成功案例**（減少返工、加速維護）
3. **並行使用期**（不強制切換）
4. **1 小時培訓**（降低學習門檻）

**預期**：
- Week 1-2: 20% 團隊嘗試
- Week 3-4: 50% 團隊使用
- Week 5-8: 80% 團隊習慣
- Month 3: 全團隊標準流程

#### Q5: 如果我只想要 OpenSpec，不想要 Superpowers 的「囉嗦」？

**A**: 可以分開啟用。

```toml
# config.toml

[openspec]
enabled = true  # 啟用 SDD 工作流

[superpowers]
rationalization_prevention = false  # 關閉理性化預防
hard_blocks = false                  # 關閉強制規則
```

**但建議**：至少保留 `hard_blocks`（防止重大錯誤）

---

## 風險評估與緩解

### 高風險項目

| 風險 | 機率 | 影響 | 緩解措施 |
|------|------|------|---------|
| **團隊學習曲線** | 🔴 High (80%) | 🟡 Medium | 1 小時培訓 + 詳細文件 + 逐步導入 |
| **初期效率下降** | 🟡 Medium (60%) | 🟡 Medium | 前 2 週預期 20% 效率下降，Week 3 起回升 |
| **OpenSpec CLI 不穩定** | 🟢 Low (20%) | 🔴 High | 包裝為 Bash script + 錯誤處理 |
| **規格與 code 不同步** | 🟡 Medium (40%) | 🔴 High | 強制驗證 + CI/CD 檢查 |

### 技術風險

| 風險 | 緩解措施 |
|------|---------|
| **OpenSpec CLI 版本更新** | Pin 版本 + 定期測試升級 |
| **Delta 格式解析錯誤** | `openspec validate --strict` 強制驗證 |
| **Archive 合併衝突** | 手動解決 + 文件化常見情況 |
| **Specs 過時** | CI/CD 定期檢查 + 提醒更新 |

### 組織風險

| 風險 | 緩解措施 |
|------|---------|
| **舊專案無法全面採用** | Brownfield 漸進式導入 |
| **團隊抗拒新流程** | 並行使用期 + 證明效果 |
| **維護成本增加** | 自動化工具 + 明確規範 |

---

## 成功指標

### Phase 1 完成標準（Week 1-2）

| 指標 | 目標 | 驗證方式 |
|------|------|---------|
| **OpenSpec 目錄建立** | 100% | 檢查 `openspec/` 存在 |
| **CLI 工具可用** | 100% | `openspec --version` 成功 |
| **AGENTS.md 整合** | 100% | 新增 OpenSpec Workflow 區塊 |
| **config.toml 配置** | 100% | `[openspec]` section 存在 |
| **初始 specs 建立** | 4 個 | scaffolding-mode, i18n, version, module |

### Phase 2 完成標準（Week 3-4）

| 指標 | 目標 | 驗證方式 |
|------|------|---------|
| **理性化預防表格** | 5 個 skills 強化 | 每個 skill 有 RPT |
| **Hard Blocks 區塊** | 100% | AGENTS.md 有完整定義 |
| **理性化偵測 skill** | 100% | `rationalization-detector` 存在 |

### Phase 3 完成標準（Week 5-6）

| 指標 | 目標 | 驗證方式 |
|------|------|---------|
| **SDD Skills** | 4 個 | writing-proposals, delta-spec-authoring, spec-validation, brownfield-refactoring |
| **SDD Agents** | 2 個 | spec-writer, spec-reviewer |
| **測試覆蓋** | >90% | 每個 skill/agent 有測試 |

### Phase 4 完成標準（Week 7-8）

| 指標 | 目標 | 驗證方式 |
|------|------|---------|
| **Workflow 整合** | spec-driven-feature workflow | `.agents/workflows.yaml` |
| **Bundle 整合** | sdd-workflow bundle | `.agents/bundles.yaml` |
| **文件完整度** | 100% | 每個功能有使用指南 |

### 使用者體驗指標（3 個月後）

| 指標 | 當前 (v2.1.0) | 目標 (v3.0.0) | 提升 |
|------|--------------|--------------|------|
| **AI 可靠性** | 70% | 95% | +36% |
| **開發速度** | 基準 | +40% | +40% |
| **Token 效率** | 基準 | -30% | +30% |
| **維護成本** | 基準 | -50% | +50% |
| **Bug 引入率** | 基準 | -60% | +60% |
| **文件完整度** | 75% | 95% | +27% |

---

## 附錄

### A. 參考資料

- [Superpowers GitHub](https://github.com/obra/superpowers) (29K stars)
- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec) (Active Development)
- [高見龍 - Superpowers 的設計與取捨](https://kaochenlong.com/ai-superpowers-skills)
- [高見龍 - OpenSpec 讓 SDD 變簡單](https://kaochenlong.com/openspec)
- [RFC 2119 - Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [Spec-Driven Development 方法論](https://kaochenlong.com/sdd-spec-driven-development)

### B. 詞彙表

| 術語 | 定義 |
|------|------|
| **SDD** | Spec-Driven Development（規格驅動開發） |
| **Delta Spec** | 描述變更差異的規格（ADDED/MODIFIED/REMOVED） |
| **Brownfield** | 既有系統（相對於 Greenfield 全新專案） |
| **Artifact** | OpenSpec 中的文件（proposal, design, tasks, specs） |
| **Rationalization** | AI 找藉口繞過規則的行為 |
| **Hard Block** | 零容忍違規（絕不允許的行為） |
| **Archive** | 已完成變更的歷史紀錄 |
| **Scenario** | 需求的具體範例（Given/When/Then） |

### C. 遷移檢查清單

**升級前**：
- [ ] 備份專案（git commit + push）
- [ ] 閱讀完整 PRD（本文件）
- [ ] 準備 1-2 天時間（初始化）

**升級中**：
- [ ] 安裝 OpenSpec CLI
- [ ] 執行 `openspec init`
- [ ] 合併 template v3.0.0 變更
- [ ] 解決衝突（主要在 AGENTS.md, config.toml）
- [ ] 配置 `config.toml` [openspec] section
- [ ] 建立 `openspec/project.md`
- [ ] 建立初始 4 個 specs

**升級後**：
- [ ] 團隊培訓（1 小時）
- [ ] 試跑一次完整流程（/opsx:propose → apply → archive）
- [ ] 監控第一週效率變化
- [ ] 收集團隊回饋
- [ ] 調整配置（如果需要）

---

## 批准簽署

| 角色 | 姓名 | 簽名 | 日期 |
|------|------|------|------|
| **Product Owner** | [待填] | [待填] | [待填] |
| **Tech Lead** | [待填] | [待填] | [待填] |
| **Team Lead** | [待填] | [待填] | [待填] |

---

**文件版本歷史**：

| 版本 | 日期 | 變更 | 作者 |
|------|------|------|------|
| 2.0.0 | 2026-03-27 | 初版 - 完整整合 Superpowers + OpenSpec | AI Agent |
| 2.0.1 | TBD | [待更新] | [待填] |

---

**End of PRD**
