# Directory Restructure Summary

**Date**: 2026-03-27  
**Reason**: Implement ADR 0013 directory structure decision

---

## Changes Made

### 1. Agent Infrastructure: `.agents/` → `.scaffolding/agents/`

**Before**:
```
.agents/
├── agents/
├── commands/
├── skills/
├── bundles.yaml
├── workflows.yaml
└── service-detection.md
```

**After**:
```
.scaffolding/agents/          # All template agent infrastructure
├── agents/
├── commands/
├── skills/                   # Template skills (v2.0 with Iron Laws)
│   ├── backend/
│   │   ├── backend-patterns-v2.md
│   │   ├── database-optimization-v2.md
│   │   └── error-handling-v2.md
│   ├── frontend/
│   │   ├── frontend-patterns-v2.md
│   │   ├── react-hooks-v2.md
│   │   └── component-design-v2.md
│   ├── universal/
│   │   ├── api-design-v2.md
│   │   └── security-review-v2.md
│   └── testing/
│       ├── e2e-testing-v2.md
│       └── unit-testing-v2.md
├── bundles.yaml
├── workflows.yaml
└── service-detection.md

.agents/                      # For project-specific agents (empty)
└── README.md
```

**Reason**: 
- Template infrastructure belongs in `.scaffolding/`
- Avoid conflicts when project itself uses AI agents
- Clear separation: template vs project

---

### 2. Documentation: `docs/` → `.scaffolding/docs/`

**Before**:
```
docs/
├── PRD-*.md                  # Template PRDs
├── PHASE_*.md                # Template completion reports
├── MIGRATION_GUIDE_V3.md     # Template migration guide
├── V3_*.md                   # Template summaries
└── adr/
    ├── 0001-*.md             # Template ADRs (0001-0013)
    └── ...
```

**After**:
```
.scaffolding/docs/
├── PRD-*.md                  # Template PRDs (moved)
├── PHASE_*.md                # Template completion reports (moved)
├── MIGRATION_GUIDE_V3.md     # Template migration guide (moved)
├── V3_*.md                   # Template summaries (moved)
└── adr/
    ├── 0001-*.md             # Template ADRs (moved, 0001-0013)
    └── ...

docs/                         # For project documentation (empty)
├── README.md                 # Usage guide
└── adr/
    ├── README.md             # ADR guide (start from 0100)
    └── (empty - for project ADRs)
```

**Reason**:
- Template docs belong in `.scaffolding/docs/`
- `docs/` reserved for project-specific documentation
- Clear separation: template docs vs project docs

---

## Skill Loading Priority (Updated)

```
1. .agents/skills/                    # Project skills (highest priority)
2. .scaffolding/agents/skills/        # Template skills (Iron Laws v2.0)
3. ~/.config/opencode/skills/         # User skills (Superpowers)
```

**Override behavior**: Same-name skills in higher priority directory override lower priority.

---

## File Counts

**Template Agent Infrastructure**:
- `.scaffolding/agents/skills/`: 10 v2.0 skills (5,000+ lines)
- `.scaffolding/agents/agents/`: 6 specialized agents
- `.scaffolding/agents/commands/`: 14 commands

**Template Documentation**:
- `.scaffolding/docs/`: 61 files
- `.scaffolding/docs/adr/`: 17 ADRs

**Project Directories** (empty, ready for use):
- `.agents/`: README only
- `docs/`: README + adr/README
- `docs/adr/`: Empty (start from 0100)

---

## AGENTS.md Updates

Updated all paths:
- `.agents/` → `.scaffolding/agents/` (8 occurrences)
- Skill Discovery Paths section (corrected priority order)
- Available Skills section (updated locations)

---

## Verification

```bash
# Verify template infrastructure in .scaffolding/
ls .scaffolding/agents/skills/*/
ls .scaffolding/docs/adr/

# Verify project directories are empty
ls .agents/           # Only README.md
ls docs/adr/          # Only README.md

# Verify all v2.0 skills exist
find .scaffolding/agents/skills -name "*-v2.md" | wc -l
# Expected: 10
```

---

## References

- **ADR 0013**: Skills Architecture - Superpowers Strictness × ECC Domain Coverage
  - Location: `.scaffolding/docs/adr/0013-skills-architecture-superpowers-strictness-ecc-coverage.md`
  - Decision 6: Directory structure adjustment
  - Rationale: Avoid conflicts, clear separation

- **AGENTS.md**: Updated all path references (lines 258, 423, 431, 566, 617, 774, 853, 953, 1207, 1214)

---

## Impact

✅ **No breaking changes** - Skills still load correctly  
✅ **Clear separation** - Template vs project  
✅ **Consistent with ADR 0013** - Implements approved design  
✅ **Future-proof** - Project can use `.agents/` without conflicts

---

**Status**: Complete. All files moved, paths updated, documentation added.
