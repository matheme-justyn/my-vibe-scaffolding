# ECC Skills v2.0 改造模板

**目的**: 統一改造 ECC skills，加上 Superpowers 風格的 Iron Laws  
**版本**: 2.0.0  
**參考**: ADR 0013 - Skills Architecture

---

## 📋 改造檢查清單

改造每個 ECC skill 時，遵循此清單：

- [ ] 保留原有 frontmatter（更新 version, 新增 enhanced_with）
- [ ] 新增「Iron Laws」章節（放在文件開頭）
- [ ] 每條 Iron Law 包含：壞範例、好範例、違反處理、不接受藉口、強制執行
- [ ] 保留原有「Implementation Details」（實作細節）
- [ ] 更新「When to Use」觸發條件
- [ ] 測試：確認 Iron Laws 明確、可執行

---

## 🎯 統一格式

### Frontmatter

```markdown
---
name: {skill-name}
description: {簡短描述 - 保持原有，但強調 Iron Laws}
version: 2.0.0
origin: ECC (everything-claude-code)
adapted_for: OpenCode
enhanced_with: Superpowers Iron Laws
last_updated: 2026-03-27
---
```

### 文件結構

```markdown
# {Skill Title}

## OpenCode Integration

**When to Use**:
- {觸發場景 1}
- {觸發場景 2}
- {觸發場景 3}

**Load this skill when**:
- {關鍵字 1}
- {關鍵字 2}

**Usage Pattern**:
```typescript
@use {skill-name}
User: "{範例使用情境}"
```

**Combines well with**:
- `{相關 skill 1}` - {說明}
- `{相關 skill 2}` - {說明}

---

## Iron Laws (Superpowers 風格)

### 1. {RULE_NAME_1}

```{language}
// ❌ BAD: {說明為什麼這是錯的}
{bad_code_example}

// ✅ GOOD: {說明為什麼這是對的}
{good_code_example}
```

**違反處理**:
- {具體行動 - 刪除/重寫/拒絕 PR}
- {何時觸發 - 在 code review/build/runtime}

**不接受藉口**:
- ❌ "{常見藉口 1}"
- ❌ "{常見藉口 2}"
- ❌ "{常見藉口 3}"

**強制執行**:
- {自動化機制 - linter rule/type check/test}
- {檢查點 - pre-commit/CI/code review}

---

### 2. {RULE_NAME_2}

{同上格式}

---

### 3. {RULE_NAME_3}

{同上格式}

---

## Implementation Details (原 ECC 內容)

### Overview

{保留原有的概述}

### When to Activate

{保留原有的啟動時機}

### Core Principles

{保留原有的核心原則}

### {其他原有章節}

{保留原有內容}

---

## Anti-Patterns (從原有內容提取或新增)

### Anti-Pattern 1: {Pattern Name}

**問題**: {描述反模式}

**範例**:
```{language}
{bad_example}
```

**為什麼錯**: {解釋}

**正確做法**: {指向對應的 Iron Law 或 Implementation Detail}

---

## Examples

{保留或增強原有範例}

---

## References

- **Origin**: ECC (everything-claude-code) by affaan-m
- **Enhanced**: Superpowers Iron Laws by Jesse Vincent (@obra)
- **ADR**: docs/adr/0013-skills-architecture-superpowers-strictness-ecc-coverage.md
```

---

## 🔧 Iron Laws 設計原則

### 原則 1: 明確性（Specificity）

**好的 Iron Law**:
```markdown
### NO SYNC CODE IN ASYNC PATHS

```javascript
// ❌ BAD
async function handler() {
  const data = fs.readFileSync('file.txt')  // Blocks event loop
}
```

**不好的 Iron Law**:
```markdown
### USE ASYNC PROPERLY

// 太模糊，AI 不知道什麼是「properly」
```

---

### 原則 2: 可執行性（Enforceability）

Iron Law 必須能夠被自動檢查或明確驗證：

**好**:
- ✅ Linter rule 可檢查
- ✅ Type system 可捕捉
- ✅ Test 可驗證
- ✅ Code review 可目視確認

**不好**:
- ❌ "寫好的程式碼" (太主觀)
- ❌ "適當的效能" (無法量化)
- ❌ "優雅的設計" (無明確標準)

---

### 原則 3: 零容忍（Zero Tolerance）

違反 Iron Law = 立即行動，無例外：

**行動類型**:
1. **刪除程式碼** - 最嚴格（用於 TDD、架構違規）
2. **拒絕 PR** - 嚴格（用於安全、效能關鍵）
3. **Build 失敗** - 標準（用於 linter、type errors）
4. **警告升級為錯誤** - 最低限度（用於逐步改善）

---

### 原則 4: 預防理性化（Rationalization Prevention）

列出 AI 常見的藉口：

**常見藉口模式**:
- "這只是原型" / "之後會重構"
- "這個案例很特殊"
- "效能要求不高"
- "時間緊迫"
- "這樣比較簡單"

**每條 Iron Law 都要預先阻擋這些藉口**

---

## 📝 改造步驟（SOP）

### Step 1: 讀取原始 ECC Skill

```bash
# 讀取原始檔案
cat .agents/skills/{category}/{skill-name}.md
```

### Step 2: 識別核心反模式

從原有內容中找出：
- 「建議避免」的做法 → 轉成 Iron Law
- 「最佳實踐」的反面 → 轉成 Iron Law
- 常見錯誤範例 → 擴充成 Iron Law

### Step 3: 設計 Iron Laws（3-5 條）

每個 skill 設計 3-5 條 Iron Laws：
- 選擇最關鍵的反模式（high impact）
- 優先選擇可自動檢查的規則
- 涵蓋該領域最常見的錯誤

### Step 4: 撰寫壞範例 + 好範例

**壞範例要求**:
- 真實世界會出現的程式碼
- 一眼看出問題所在
- 加上註解說明為什麼錯

**好範例要求**:
- 直接對應壞範例
- 展示正確做法
- 加上註解說明為什麼對

### Step 5: 定義違反處理

明確說明違反時的行動：
```markdown
**違反處理**:
- 在 code review 階段拒絕 PR
- 要求刪除違規程式碼並重寫
- 不接受「加個 TODO」或「之後修」
```

### Step 6: 列出理性化藉口

根據該領域常見藉口列表：
```markdown
**不接受藉口**:
- ❌ "這只是測試程式碼" → 測試也要遵守規則
- ❌ "效能影響很小" → 累積起來就大
- ❌ "deadline 快到了" → 技術債更貴
```

### Step 7: 定義強制執行機制

說明如何自動化檢查：
```markdown
**強制執行**:
- ESLint rule: `no-sync-in-async`
- TypeScript: 型別檢查會報錯
- Pre-commit hook: 執行 linter
```

### Step 8: 保留原有內容

將原有的「Implementation Details」章節完整保留：
- Overview
- Core Principles
- Best Practices
- Examples

### Step 9: 更新 Frontmatter

```markdown
---
version: 2.0.0  # 從 1.0.0 升級
enhanced_with: Superpowers Iron Laws  # 新增
last_updated: 2026-03-27  # 新增
---
```

### Step 10: 驗證改造結果

檢查清單：
- [ ] Iron Laws 明確且可執行
- [ ] 壞範例 + 好範例清楚
- [ ] 違反處理具體可行
- [ ] 藉口清單涵蓋常見情況
- [ ] 原有內容完整保留
- [ ] Frontmatter 正確更新

---

## 🎯 範例：backend-patterns 改造對照

### 改造前（ECC 原版）

```markdown
---
name: backend-patterns
description: Node.js backend patterns
version: 1.0.0
---

# Backend Patterns

## Best Practices

建議使用 async/await 處理非同步操作...
```

### 改造後（v2.0 with Iron Laws）

```markdown
---
name: backend-patterns
description: Node.js backend patterns with Iron Laws enforcement
version: 2.0.0
origin: ECC (everything-claude-code)
enhanced_with: Superpowers Iron Laws
---

# Backend Patterns

## Iron Laws

### 1. NO SYNC CODE IN ASYNC PATHS

```javascript
// ❌ BAD: Blocks event loop
async function handler() {
  const data = fs.readFileSync('file.txt')
}

// ✅ GOOD: Non-blocking
async function handler() {
  const data = await fs.promises.readFile('file.txt')
}
```

**違反處理**: 拒絕 PR，要求重寫

**不接受藉口**:
- ❌ "這只是小檔案" → 仍會阻塞
- ❌ "效能差異不大" → 累積起來大

**強制執行**: ESLint `no-sync-in-async` rule

---

## Implementation Details

{原有的最佳實踐內容...}
```

---

## 📊 改造進度追蹤

### 高優先度（Phase 1A）

| Skill | Iron Laws 數量 | 狀態 | 完成日期 |
|-------|---------------|------|---------|
| backend-patterns | 3 | ⏳ 進行中 | - |
| frontend-patterns | 3 | 📝 待改造 | - |
| api-design | 3 | 📝 待改造 | - |
| security-review | 5 | 📝 待改造 | - |
| error-handling | 3 | 📝 待改造 | - |

### 中優先度（Phase 1B）

| Skill | Iron Laws 數量 | 狀態 | 完成日期 |
|-------|---------------|------|---------|
| react-hooks | 3 | 📝 待改造 | - |
| database-optimization | 3 | 📝 待改造 | - |
| component-design | 3 | 📝 待改造 | - |
| e2e-testing | 3 | 📝 待改造 | - |
| unit-testing | 3 | 📝 待改造 | - |

### 低優先度（Phase 2）

| Skill | Iron Laws 數量 | 狀態 | 完成日期 |
|-------|---------------|------|---------|
| coding-standards | 3 | 📝 待改造 | - |

---

## 🔗 相關資源

- **ADR 0013**: `docs/adr/0013-skills-architecture-superpowers-strictness-ecc-coverage.md`
- **衝突分析**: `docs/SKILLS_CONFLICT_ANALYSIS.md`
- **Superpowers 參考**: `~/.config/opencode/skills/superpowers/test-driven-development/`
- **遷移指南**: `docs/MIGRATION_GUIDE_V3.md`

---

**此模板確保所有 ECC skills 改造的一致性與品質** ✅
