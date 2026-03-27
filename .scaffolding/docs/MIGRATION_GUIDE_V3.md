# Migration Guide: v2.x → v3.0.0

**Version**: 3.0.0  
**Status**: Phase 1A Complete ✅  
**Last Updated**: 2026-03-27

---

## Overview

Version 3.0.0 integrates **OpenSpec** (Spec-Driven Development) and **Superpowers Iron Laws** into my-vibe-scaffolding, providing:

- **Superpowers Iron Laws**: 25 strict rules preventing common production failures (5 per domain)
- **Directory Restructuring**: Template infrastructure moved to `.scaffolding/agents/`
- **Skill Transformations**: 5 ECC skills enhanced with Iron Laws (v2.0)
- **Spec-Driven Development**: OpenSpec workflow (opt-in, disabled by default)
- **One-Command Upgrade**: Painless migration with automatic backup

**Philosophy**: Superpowers strictness × ECC breadth = comprehensive, enforceable standards.

---

## What's Changing

### Critical: Directory Restructuring

**Template infrastructure relocated** to avoid conflicts with project-specific agents:

```diff
- .agents/                         # OLD: Template + project mixed
-   ├── skills/
-   ├── agents/
-   ├── commands/
-   ├── bundles.yaml
-   └── workflows.yaml

+ .scaffolding/agents/             # NEW: Template infrastructure only
+   ├── skills/
+   │   ├── backend/
+   │   │   ├── backend-patterns.md (v2.0 - 5 Iron Laws)
+   │   │   └── error-handling.md (v2.0 - 5 Iron Laws)
+   │   ├── frontend/
+   │   │   └── frontend-patterns.md (v2.0 - 5 Iron Laws)
+   │   └── universal/
+   │       ├── api-design.md (v2.0 - 5 Iron Laws)
+   │       └── security-review.md (v2.0 - 5 Iron Laws)
+   ├── agents/
+   ├── commands/
+   ├── bundles.yaml
+   └── workflows.yaml
+
+ .agents/                          # NEW: Project-specific agents only
+   ├── .gitkeep
+   └── README.md (usage guide)
```

**Why this matters**:
- Projects building AI agent systems had `.agents/` conflicts
- Clear separation: template vs project code
- Easier template updates (no merge conflicts)

### Transformed Skills (5 with Iron Laws)

Each skill now includes **5 Iron Laws** with Superpowers-style enforcement:

**1. backend-patterns v2.0**:
- NO SYNC CODE IN ASYNC PATHS
- NO NAKED PROMISES (must have error handling)
- NO UNHANDLED ASYNC ERRORS
- NO CALLBACK HELL (max 2 levels)
- NO BLOCKING OPERATIONS IN EVENT LOOP

**2. frontend-patterns v2.0**:
- NO PROP DRILLING BEYOND 2 LEVELS
- NO INLINE EVENT HANDLERS IN LOOPS
- NO UNKEYED LISTS OR INDEX-BASED KEYS
- NO USEEFFECT DEPENDENCY VIOLATIONS
- NO DIRECT STATE MUTATIONS

**3. api-design v2.0**:
- NO MISMATCHED HTTP METHODS AND STATUS CODES
- NO NAKED 500 ERRORS (MUST BE GENERIC)
- NO PAGINATION WITHOUT HYPERMEDIA LINKS
- NO VERBS IN RESOURCE URLS
- NO UNVERSIONED APIS

**4. security-review v2.0**:
- NO SECRETS IN CODE OR LOGS
- NO SQL CONCATENATION (PARAMETERIZED QUERIES ONLY)
- NO EVAL OR UNSAFE DYNAMIC CODE
- NO AUTHENTICATION IN LOCALSTORAGE (HTTPONLY COOKIES ONLY)
- NO MISSING INPUT VALIDATION (WHITELIST SCHEMA REQUIRED)

**5. error-handling v2.0**:
- NO EMPTY CATCH BLOCKS
- NO SWALLOWED ERRORS (MUST LOG OR THROW)
- NO STRING ERRORS (USE ERROR CLASSES)
- NO 200 OK WITH ERROR IN BODY
- NO UNHANDLED ASYNC REJECTIONS

**Iron Laws Format** (per law):
```markdown
### N. NO [VIOLATION_PATTERN]

❌ BAD: [code example]
✅ GOOD: [code example]
Violation Handling: [what to do]
No Excuses: [blocked rationalizations]
Enforcement: [mechanism]
```

### ECC TDD Workflow Deleted

**Decision**: Delete ECC `tdd-workflow.md` (flexible version), keep only Superpowers `test-driven-development` (Iron Laws version).

**Reason**: Conflicting approaches - Superpowers' stricter version aligns better with v3.0.0 philosophy.

**Action**: Upgrade script automatically deletes `.scaffolding/agents/skills/universal/tdd-workflow.md`.

### New Directory Structure

```
my-vibe-scaffolding/
├── .scaffolding/agents/            # NEW: Template infrastructure (relocated)
│   ├── skills/
│   │   ├── backend/
│   │   │   ├── backend-patterns.md (v2.0)
│   │   │   └── error-handling.md (v2.0)
│   │   ├── frontend/
│   │   │   └── frontend-patterns.md (v2.0)
│   │   ├── universal/
│   │   │   ├── api-design.md (v2.0)
│   │   │   └── security-review.md (v2.0)
│   │   └── ... (other existing skills)
│   ├── agents/                     # 6 specialized agents
│   ├── commands/                   # 11 → 14 commands (3 new SDD)
│   ├── bundles.yaml
│   └── workflows.yaml
│
├── .scaffolding/openspec/          # NEW: OpenSpec SDD system
│   ├── README.md
│   ├── project.md                  # Project context
│   ├── specs/                      # Active specifications
│   ├── changes/                    # Proposed changes
│   └── changes/archive/            # Completed changes
│
├── .agents/                        # NEW: Project-specific agents only
│   ├── .gitkeep
│   └── README.md                   # Usage guide
│
├── config.toml                     # MODIFIED: Add [sdd] section
├── AGENTS.md                       # MODIFIED: Update path references
└── ...                             # Other existing files
```

### Configuration Changes

**New `config.toml` section** (SDD disabled by default):

```toml
# ==============================================================================
# Spec-Driven Development (SDD) Configuration (3.0.0+)
# ==============================================================================

[sdd]
enabled = false  # Set to true when ready to use SDD
workflow = "openspec"  # openspec | traditional | hybrid
strict_mode = true
auto_archive = true

[sdd.artifacts]
proposal_required = true
design_required = true
tasks_required = true

[sdd.rationalization_prevention]
enabled = true
enforce_mandatory_skills = true
block_excuses = [
    "just a simple question",
    "I need context first",
    "let me check files quickly",
]

[sdd.thresholds]
require_spec_for = "medium_and_above"
complex_if_files_modified = 3
complex_if_lines_changed = 150
complex_if_new_dependencies = true
```

---

## Upgrade Path

### Prerequisites

**Required**:
- my-vibe-scaffolding v2.1.0+
- Git repository initialized
- No uncommitted changes (will be checked)

**Optional**:
- Node.js 18+ (for future OpenSpec CLI integration)

### One-Command Upgrade (Recommended)

```bash
# From project root
./.scaffolding/scripts/upgrade-to-v3.sh
```

**What this does**:

1. **Pre-flight checks**:
   - Version detection (must be v2.1.0+)
   - Git status (must be clean)
   - Backup current state to `.upgrade-backup-{timestamp}/`

2. **Migration steps**:
   - Relocate `.agents/` → `.scaffolding/agents/`
   - Delete ECC `tdd-workflow.md`
   - Copy transformed skills (v2.0 with Iron Laws)
   - Create `.scaffolding/openspec/` structure
   - Merge `[sdd]` section into `config.toml`
   - Update `AGENTS.md` path references

3. **Validation**:
   - Verify new structure exists
   - Check config.toml syntax
   - Validate skill loading

4. **Post-upgrade**:
   - Generate migration report
   - Provide rollback instructions

### Preview Changes (Dry Run)

```bash
# See what will happen without making changes
./.scaffolding/scripts/upgrade-to-v3.sh --dry-run
```

---

## Migration Checklist

### Pre-Migration

- [ ] Current version is v2.1.0 or higher
- [ ] Git repository clean (no uncommitted changes)
- [ ] Read this migration guide completely
- [ ] Backup created (automatic via script)

### During Migration

- [ ] Run upgrade script: `./.scaffolding/scripts/upgrade-to-v3.sh`
- [ ] Review migration report
- [ ] Check config.toml merged correctly
- [ ] Verify `.scaffolding/agents/` structure exists
- [ ] Verify `.scaffolding/openspec/` structure exists
- [ ] Test skill loading: `@use backend-patterns`

### Post-Migration

- [ ] Review transformed skills (v2.0 Iron Laws)
- [ ] Test Iron Laws enforcement (try violating one)
- [ ] Configure SDD preferences in config.toml (optional)
- [ ] Update team documentation

---

## File Relocation Manifest

**What moves where** (automatic migration):

| Current Location | New Location | Action | Reason |
|------------------|--------------|--------|--------|
| `.agents/skills/` | `.scaffolding/agents/skills/` | **MOVE** | Template infrastructure relocation |
| `.agents/agents/` | `.scaffolding/agents/agents/` | **MOVE** | Template infrastructure relocation |
| `.agents/commands/` | `.scaffolding/agents/commands/` | **MOVE** | Template infrastructure relocation |
| `.agents/bundles.yaml` | `.scaffolding/agents/bundles.yaml` | **MOVE** | Template infrastructure relocation |
| `.agents/workflows.yaml` | `.scaffolding/agents/workflows.yaml` | **MOVE** | Template infrastructure relocation |
| `.agents/README.md` | `.scaffolding/agents/README.md` | **MOVE** | Template infrastructure relocation |
| `.agents/` | (empty) | **CREATE** `.gitkeep` + README | Project-specific agents placeholder |
| `.scaffolding/agents/skills/universal/tdd-workflow.md` | (deleted) | **DELETE** | Superseded by Superpowers version |
| (none) | `.scaffolding/agents/skills/backend/backend-patterns.md` | **COPY** | v2.0 with Iron Laws |
| (none) | `.scaffolding/agents/skills/backend/error-handling.md` | **COPY** | v2.0 with Iron Laws |
| (none) | `.scaffolding/agents/skills/frontend/frontend-patterns.md` | **COPY** | v2.0 with Iron Laws |
| (none) | `.scaffolding/agents/skills/universal/api-design.md` | **COPY** | v2.0 with Iron Laws |
| (none) | `.scaffolding/agents/skills/universal/security-review.md` | **COPY** | v2.0 with Iron Laws |
| (none) | `.scaffolding/openspec/` | **CREATE** | New OpenSpec directory tree |
| `config.toml` | (same) | **MERGE** | Add `[sdd]` section |
| `AGENTS.md` | (same) | **MODIFY** | Update `.agents/` → `.scaffolding/agents/` references |

**Preserved files** (no changes):
- All existing Superpowers skills in `~/.config/opencode/skills/superpowers/`
- All `.scaffolding/docs/` files
- All `.scaffolding/scripts/` files (except new ones)
- `i18n/`, `data/`, `.github/`, `.vscode/`

---

## Iron Laws Enforcement

### How Iron Laws Work

Each v2.0 skill includes 5 non-negotiable rules in this format:

```markdown
### N. NO [VIOLATION_PATTERN]

❌ BAD:
[code example showing violation]

✅ GOOD:
[code example showing correct approach]

Violation Handling: [specific action to take]

No Excuses:
- ❌ "[common excuse 1]"
- ❌ "[common excuse 2]"

Enforcement: [tooling/process]
```

### Example: backend-patterns v2.0

**Iron Law 1: NO SYNC CODE IN ASYNC PATHS**

❌ **BAD**:
```typescript
app.get('/users', async (req, res) => {
  const users = await db.users.findAll()
  const processed = users.map(u => {
    const data = fs.readFileSync(`/data/${u.id}.json`)  // Blocks!
    return JSON.parse(data)
  })
  res.json(processed)
})
```

✅ **GOOD**:
```typescript
app.get('/users', async (req, res) => {
  const users = await db.users.findAll()
  const processed = await Promise.all(
    users.map(async u => {
      const data = await fs.promises.readFile(`/data/${u.id}.json`)
      return JSON.parse(data)
    })
  )
  res.json(processed)
})
```

**Violation Handling**: Rewrite with async/await or promises

**No Excuses**:
- ❌ "It's just one file"
- ❌ "Files are small"

**Enforcement**: ESLint rule `no-sync`, code review

### Testing Iron Laws

After upgrade, verify enforcement:

```bash
# Load transformed skill
@use backend-patterns

# Try violating Iron Law (AI should block)
User: "Read this file synchronously in the async handler"
AI: "❌ Violation: NO SYNC CODE IN ASYNC PATHS. Must use fs.promises.readFile"
```

---

## Rollback Procedure

**If upgrade fails or causes issues**:

### Immediate Rollback

```bash
# Automatic rollback (if upgrade failed)
# Script creates rollback instructions in migration report

# Manual rollback
rm -rf .scaffolding/agents/
rm -rf .scaffolding/openspec/
cp -r .upgrade-backup-{timestamp}/.agents .agents
cp .upgrade-backup-{timestamp}/config.toml config.toml
cp .upgrade-backup-{timestamp}/AGENTS.md AGENTS.md
```

### Selective Rollback (Keep some v3 features)

```bash
# Disable SDD but keep Iron Laws skills
# Edit config.toml:
[sdd]
enabled = false

# Remove OpenSpec directory
rm -rf .scaffolding/openspec/

# Keep transformed skills in .scaffolding/agents/
```

### Report Issue

If you encounter migration issues:

1. **Create issue**: https://github.com/matheme-justyn/my-vibe-scaffolding/issues
2. **Include**:
   - Migration report: `.upgrade-backup-{timestamp}/migration-report.md`
   - Error messages
   - `config.toml` contents
   - Current version: `cat VERSION`

---

## FAQ

### Q1: Why relocate .agents/ to .scaffolding/agents/?

**A**: User reported conflict when building AI agent systems. Projects need `.agents/` for their own agent code. Template infrastructure now lives in `.scaffolding/agents/` to avoid conflicts.

### Q2: What happened to ECC tdd-workflow?

**A**: Deleted. Superseded by Superpowers' `test-driven-development` skill which has stricter Iron Laws enforcement. v3.0.0 philosophy favors Superpowers strictness.

### Q3: Do I need to enable SDD workflow?

**A**: No, it's opt-in. `[sdd] enabled = false` by default. You can use v3.0.0 just for Iron Laws skills without enabling SDD.

### Q4: Can I still use old v1.0 skills?

**A**: Old skills are preserved but v2.0 versions are strongly recommended. Iron Laws prevent common production issues.

### Q5: Will this break my existing projects?

**A**: No. Upgrade is non-destructive:
- Automatic backup created
- SDD disabled by default
- Old skills still work (but deprecated)
- Path updates are automatic

### Q6: How do I test transformed skills?

**A**:
```bash
# Load v2.0 skill
@use backend-patterns

# AI will enforce Iron Laws
User: "Write this async function with sync file read"
AI: "❌ Violation: NO SYNC CODE IN ASYNC PATHS..."
```

### Q7: Can I create project-specific agents?

**A**: Yes! That's why `.agents/` now exists:

```
.agents/                    # Your project agents
├── skills/
│   └── my-custom-skill/
├── agents/
│   └── my-project-agent/
└── commands/
    └── my-command/

.scaffolding/agents/        # Template agents (don't edit)
```

### Q8: What if I want to enable SDD later?

**A**:
```toml
# Edit config.toml
[sdd]
enabled = true  # Change from false to true
```

Then use:
- `@use sdd-propose` - Create change proposals
- `@use sdd-apply` - Apply approved changes
- `@use sdd-archive` - Archive completed changes

---

## Expected Benefits

### Immediate (After Migration)

- ✅ Iron Laws enforcement active
- ✅ 5 transformed skills with strict rules
- ✅ Directory structure cleaned up
- ✅ OpenSpec infrastructure ready (if you enable it)

### Short-Term (1 Week)

- 🎯 **Fewer production bugs**: Iron Laws catch issues early
- 📉 **Less rework**: Violations blocked before commit
- 📚 **Clear standards**: 25 rules across 5 domains

### Long-Term (1 Month+)

- ⚡ **+30% code quality**: Consistent patterns enforced
- 🔒 **Better security**: Security Iron Laws prevent vulnerabilities
- 🧠 **Knowledge transfer**: New developers follow Iron Laws
- 🚀 **Faster reviews**: Iron Laws provide objective criteria

---

## Support

### Resources

- **ADR 0013**: `docs/adr/0013-ecc-superpowers-iron-laws-integration.md`
- **Phase 1A Completion**: `docs/PHASE_1A_COMPLETION.md`
- **Superpowers**: https://github.com/obra/superpowers
- **Issues**: https://github.com/matheme-justyn/my-vibe-scaffolding/issues

### Getting Help

1. **Read migration report**: `.upgrade-backup-{timestamp}/migration-report.md`
2. **Test Iron Laws**: Try violating a rule and verify AI blocks it
3. **Ask in issues**: Tag with `v3-migration`
4. **Rollback if stuck**: See "Rollback Procedure" above

---

**Version**: 3.0.0  
**Phase 1A Complete**: ✅ 5 high-priority skills transformed  
**Phase 1B Next**: 5 medium-priority skills (react-hooks, database-optimization, component-design, e2e-testing, unit-testing)  
**Last Updated**: 2026-03-27
