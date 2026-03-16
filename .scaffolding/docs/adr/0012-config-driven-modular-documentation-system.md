# ADR 0012: Config-Driven Modular Documentation System

## Status

Accepted

## Date

2026-03-16

## Context

### Background

After deciding to rename `.scaffolding/` to `.scaffolding/` (ADR 0011), we faced a series of related decisions about how to organize documentation and make it adaptive to different project types. The key questions were:

1. How should documentation modules be loaded? (All at once vs conditional)
2. What modules are needed? (Software only vs comprehensive)
3. How to handle multilingual PR templates?
4. How to manage terminology across different domains?

### Previous State (v1.15.0)

```
my-vibe-scaffolding/
├── .agents/                    # AI agent configurations
│   ├── agents/ (6 files)
│   ├── skills/ (16 files)
│   ├── commands/ (11 files)
│   └── rules/ (5 files)
├── AGENTS.md (1,441 lines)     # Monolithic config file
├── config.toml.example         # Basic i18n config only
└── docs/                       # Project documentation
```

**Limitations**:
- AGENTS.md growing too large (1,441 lines)
- No conditional loading (AI loads everything every time)
- Software development focused only
- No support for academic/documentation projects
- Single-language PR template
- No centralized terminology management

### Research & Decision Process

We analyzed 8 PRs from a reference project and conducted systematic research through:
- **librarian agent**: Industry naming conventions for AI agent configs
- **explore agent**: everything-claude-code architecture analysis
- **User requirements**: Support academic research, translation projects, documentation work

**Key Insights**:
1. **`.agents/` is emerging as cross-tool standard** (Microsoft VSCode, Qwen Code)
2. **Config-driven systems are more flexible** than hardcoded assumptions
3. **MECE principle** ensures comprehensive coverage without overlap
4. **Domain-specific terminology** varies significantly (same term, different translations)

## Decision

### Architecture: Config-Driven Modular System

```
my-vibe-scaffolding/
├── .scaffolding/                      # Scaffolding framework
│   ├── docs/                          # Documentation modules
│   │   ├── STYLE_GUIDE.md             # Core: Writing style
│   │   ├── GIT_WORKFLOW.md            # Core: Git conventions
│   │   ├── TESTING_STRATEGY.md        # Core: Testing patterns
│   │   ├── SECURITY_CHECKLIST.md      # Core: Security review
│   │   ├── FRONTEND_PATTERNS.md       # Domain: Frontend
│   │   ├── BACKEND_PATTERNS.md        # Domain: Backend
│   │   ├── API_DESIGN.md              # Domain: API design
│   │   ├── DATABASE_CONVENTIONS.md    # Domain: Database
│   │   ├── ACADEMIC_WRITING.md        # Academic: APA/MLA/Chicago
│   │   ├── CITATION_MANAGEMENT.md     # Academic: Zotero/Mendeley
│   │   ├── TRANSLATION_GUIDE.md       # Academic: Translation workflow
│   │   ├── LITERATURE_REVIEW.md       # Academic: Research methods
│   │   └── ... (31 modules total)
│   │
│   ├── terminology/                   # Terminology system
│   │   ├── terminology.md             # Common terms (always loaded)
│   │   ├── software/
│   │   │   ├── common.md
│   │   │   ├── frontend.md
│   │   │   ├── backend.md
│   │   │   ├── database.md
│   │   │   ├── devops.md
│   │   │   └── security.md
│   │   ├── academic/
│   │   │   ├── common.md
│   │   │   ├── computer-science.md
│   │   │   ├── social-science.md
│   │   │   ├── humanities.md
│   │   │   ├── natural-science.md
│   │   │   └── medicine.md
│   │   ├── documentation/
│   │   │   ├── technical-writing.md
│   │   │   ├── api-docs.md
│   │   │   └── user-guides.md
│   │   └── project/
│   │       └── custom.md              # User extensible
│   │
│   └── templates/                     # File templates
│       └── pr/
│           ├── PULL_REQUEST_TEMPLATE.zh-TW.md
│           ├── PULL_REQUEST_TEMPLATE.en-US.md
│           ├── PULL_REQUEST_TEMPLATE.zh-CN.md
│           └── PULL_REQUEST_TEMPLATE.ja-JP.md
│
├── .agents/                           # User customizations
│   ├── skills/                        # Project-specific skills
│   └── terminology/
│       └── custom.md                  # Project-specific terms
│
├── AGENTS.md                          # Core config + loading protocol
└── config.toml                        # Configuration file
```

### 1. Module System (31 Modules, MECE)

**Core Modules (5)** - Always loaded:
- STYLE_GUIDE.md
- TERMINOLOGY.md (references terminology/ files)
- GIT_WORKFLOW.md
- TESTING_STRATEGY.md
- SECURITY_CHECKLIST.md

**Software Development (6)** - Loaded based on `project.type`:
- FRONTEND_PATTERNS.md (frontend, fullstack)
- BACKEND_PATTERNS.md (backend, fullstack)
- API_DESIGN.md (backend, fullstack)
- DATABASE_CONVENTIONS.md (backend, fullstack)
- CLI_DESIGN.md (cli)
- LIBRARY_DESIGN.md (library)

**Academic & Documentation (6)** - Loaded based on `project.type`:
- ACADEMIC_WRITING.md (academic) - APA/MLA/Chicago formats
- CITATION_MANAGEMENT.md (academic) - Zotero/Mendeley
- TRANSLATION_GUIDE.md (translation, academic)
- LITERATURE_REVIEW.md (academic)
- RESEARCH_ORGANIZATION.md (academic)
- DOCUMENT_STRUCTURE.md (documentation, academic)

**Feature Modules (4)** - Loaded based on `project.features`:
- I18N_GUIDE.md (i18n feature)
- AUTH_IMPLEMENTATION.md (auth feature)
- REALTIME_PATTERNS.md (realtime feature)
- FILE_HANDLING.md (upload feature)

**Quality Modules (4)** - Loaded based on `project.quality`:
- PERFORMANCE_OPTIMIZATION.md
- TROUBLESHOOTING.md
- PRODUCTION_READINESS.md
- ACCESSIBILITY.md

**Collaboration (4)** - Loaded conditionally:
- README_STRUCTURE.md (README generation)
- ADR_TEMPLATE.md (ADR creation)
- RELEASE_PROCESS.md (versioning)
- ONBOARDING_GUIDE.md (new member)

**Scaffolding (2)** - Loaded when in scaffolding mode:
- SCAFFOLDING_DEV_GUIDE.md
- MODE_GUIDE.md

### 2. Conditional Loading Protocol

**AGENTS.md includes loading instructions**:
```markdown
## Module Loading Protocol

### How It Works
1. Read config.toml on session start
2. Determine active modules based on project.type and project.features
3. Load modules conditionally when task matches trigger keywords

### Module Loading Table

| Task Type | Trigger Keywords | Modules to Load | Priority |
|-----------|------------------|-----------------|----------|
| Documentation Writing | "寫文件", "documentation", "edit *.md" | STYLE_GUIDE.md, TERMINOLOGY.md | MUST |
| Code Commit | "commit", "提交", "git commit" | GIT_WORKFLOW.md | MUST |
| Security Implementation | "auth", "security", "認證", "安全" | SECURITY_CHECKLIST.md, AUTH_IMPLEMENTATION.md | MUST |
| ... | ... | ... | ... |
```

### 3. Config.toml Structure

```toml
[project]
# Project type determines which domain modules load
type = "fullstack"  # frontend | backend | fullstack | cli | library | academic | documentation | translation | other

# Project features determine which feature modules load
features = [
  "api",        # API_DESIGN.md
  "database",   # DATABASE_CONVENTIONS.md
  "auth",       # AUTH_IMPLEMENTATION.md
  "i18n",       # I18N_GUIDE.md
]

# Quality requirements determine which quality modules load
quality = [
  "performance",   # PERFORMANCE_OPTIMIZATION.md
  "accessibility", # ACCESSIBILITY.md
]

[academic]
# Academic settings (only for type = "academic")
citation_style = "APA"  # APA | MLA | Chicago | IEEE | Vancouver
field = "computer_science"  # computer_science | social_science | humanities | natural_science | medicine
primary_language = "zh-TW"
secondary_language = "en-US"

[github]
# PR template settings
use_pr_template = true  # Generate .github/PULL_REQUEST_TEMPLATE.md
# Template language follows [locale].primary

[modules]
# Manual overrides
always_enabled = [
  "STYLE_GUIDE",
  "GIT_WORKFLOW",
]
manual_enabled = []
manual_disabled = []

[terminology]
# Terminology loading priority
priority = ["project", "domain", "common"]  # project > domain > common
```

### 4. Multilingual PR Template System

**Template files** (4 languages):
- `.scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.zh-TW.md`
- `.scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.en-US.md`
- `.scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.zh-CN.md`
- `.scaffolding/templates/pr/PULL_REQUEST_TEMPLATE.ja-JP.md`

**Generation script**: `.scaffolding/scripts/generate-pr-template.sh`
- Reads `[locale].primary` from config.toml
- Copies appropriate template to `.github/PULL_REQUEST_TEMPLATE.md`
- Respects `[github].use_pr_template` setting

### 5. Terminology System

**Folder structure**:
```
.scaffolding/terminology/
├── terminology.md              # Common terms (always loaded)
├── software/ (6 files)         # Software development domain
├── academic/ (6 files)         # Academic domain
├── documentation/ (3 files)    # Documentation domain
└── project/custom.md           # Placeholder for user terms
```

**Loading logic**:
```
Priority 1 (Highest): .agents/terminology/custom.md    # Project-specific
Priority 2: Domain-specific files (frontend.md, etc.)  # Feature context
Priority 3: Common files (software/common.md)          # General context
Priority 4 (Lowest): terminology.md                    # Universal fallback
```

**Why domain separation**:
Same term, different translations across domains:

| Term | Software Dev | Academic | Documentation |
|------|--------------|----------|---------------|
| "Framework" | 框架 (kuàngjià) | 理論框架 (lǐlùn kuàngjià) | 架構 (jiàgòu) |
| "Method" | 方法 (fāngfǎ) | 研究方法 (yánjiū fāngfǎ) | 操作方式 (cāozuò fāngshì) |
| "Implementation" | 實作 (shízuò) | 實施 (shíshī) | 執行 (zhíxíng) |

### 6. Interactive Installation

**New script**: `.scaffolding/scripts/init-project-interactive.sh`

**Flow**:
1. Select project type (9 options: frontend/backend/fullstack/cli/library/academic/documentation/translation/other)
2. If academic: Select citation style (APA/MLA/Chicago/IEEE/Vancouver) and field
3. Select features (multi-select: api, database, auth, i18n, etc.)
4. Select quality requirements (performance, accessibility, production)
5. Select primary language (zh-TW/en-US/zh-CN/ja-JP)
6. Generate config.toml with selected settings
7. Display active modules
8. Generate PR template
9. Show active terminology files

## Rationale

### Why 31 Modules (Not Less)

| Reason | Explanation |
|--------|-------------|
| **Comprehensive coverage** | Supports software dev, academic research, documentation, translation |
| **MECE principle** | Each module covers distinct area, no overlap |
| **Scalable** | Easy to add new modules without affecting existing ones |
| **Maintainable** | Small, focused files easier to update than monolithic AGENTS.md |

### Why Config-Driven (Not Hardcoded)

| Reason | Explanation |
|--------|-------------|
| **Flexibility** | Same scaffolding supports vastly different project types |
| **User control** | Users explicitly choose what they need |
| **Performance** | AI loads only relevant modules (token efficiency) |
| **Upgradability** | New modules don't affect existing projects |

### Why Terminology Folders (Not Single File)

| Reason | Explanation |
|--------|-------------|
| **Domain context** | Same term translates differently in different domains |
| **Selective loading** | Load only terminology relevant to project type |
| **Extensibility** | Users can add project-specific terms without modifying scaffolding |
| **Conflict resolution** | Clear priority system (project > domain > common) |

### Why Multilingual PR Templates (Not English Only)

| Reason | Explanation |
|--------|-------------|
| **Localization** | Teams work in their preferred language |
| **Consistency** | Template language matches documentation language |
| **Accessibility** | Lowers barrier for non-English speakers |
| **Professionalism** | Shows attention to international users |

### Why AGENTS.md Partial Integration (Not Full Separation)

| Reason | Explanation |
|--------|-------------|
| **Quick reference** | Common conventions inline for fast lookup |
| **Reduced friction** | No need to load files for basic questions |
| **80/20 rule** | 20% of conventions cover 80% of use cases |
| **Progressive disclosure** | Basic inline, details in modules |

## Consequences

### Positive

- ✅ **Scalability**: Easy to add new project types (e.g., mobile, embedded)
- ✅ **Performance**: AI loads ~5-10 modules instead of all 31
- ✅ **Maintainability**: Small, focused modules easier to update
- ✅ **Flexibility**: Same scaffolding supports radically different projects
- ✅ **User empowerment**: Users control which modules are active
- ✅ **Internationalization**: Native multilingual support
- ✅ **Terminology consistency**: Centralized, domain-aware term management
- ✅ **Extensibility**: Users can add custom modules and terminology

### Negative

- ❌ **Migration complexity**: Existing projects need to update to 2.0.0
- ❌ **Initial setup overhead**: Users must configure config.toml
- ❌ **File proliferation**: 31 module files + terminology files
- ❌ **Maintenance burden**: More files to keep synchronized
- ❌ **Learning curve**: Users need to understand conditional loading
- ❌ **Documentation effort**: Each module needs comprehensive content

### Mitigation Strategies

| Challenge | Mitigation |
|-----------|-----------|
| Migration complexity | Provide MIGRATION_GUIDE.md with step-by-step instructions |
| Setup overhead | Interactive script guides users through configuration |
| File proliferation | Clear folder structure, README in each folder |
| Maintenance | Modules are independent, can update individually |
| Learning curve | AGENTS.md includes clear loading protocol explanation |
| Documentation | Prioritize high-use modules first, defer low-priority ones |

## Implementation Plan

### Phase 1: Foundation (Breaking Changes)
- [x] ADR 0012 (this document)
- [ ] Version bump to 2.0.0
- [ ] Rename `.scaffolding/` → `.scaffolding/`
- [ ] Update all path references in scripts and docs
- [ ] Update config.toml.example with full structure

### Phase 2: Terminology System
- [ ] Create `.scaffolding/terminology/` structure
- [ ] Write `terminology.md` (common terms)
- [ ] Write `software/common.md`, `software/frontend.md`, `software/backend.md`
- [ ] Write `academic/common.md`, `academic/computer-science.md`

### Phase 3: PR Template System
- [ ] Create `.scaffolding/templates/pr/` folder
- [ ] Write PR templates (zh-TW, en-US, zh-CN, ja-JP)
- [ ] Create `generate-pr-template.sh` script

### Phase 4: AGENTS.md Updates
- [ ] Add Module Loading Protocol section
- [ ] Add complete Module Loading Table
- [ ] Add Terminology loading logic
- [ ] Simplify Coding Conventions (keep core, reference STYLE_GUIDE)

### Phase 5: Core Documentation Modules
- [ ] Create `.scaffolding/docs/` folder
- [ ] Write STYLE_GUIDE.md
- [ ] Write GIT_WORKFLOW.md (merge commit/PR/review guidelines)
- [ ] Write ACADEMIC_WRITING.md
- [ ] Write CITATION_MANAGEMENT.md

### Phase 6: Remaining Modules (Defer Non-Critical)
- [ ] Write high-priority modules (TESTING_STRATEGY, SECURITY_CHECKLIST, API_DESIGN, etc.)
- [ ] Defer low-priority modules (can be added incrementally)

### Phase 7: Interactive Installation
- [ ] Update `init-project-interactive.sh` with all options
- [ ] Add academic project settings
- [ ] Add feature selection
- [ ] Integrate PR template generation
- [ ] Display active modules and terminology files

### Phase 8: Testing & Validation
- [ ] Test installation flow (all project types)
- [ ] Validate config.toml generation
- [ ] Validate PR template generation (all languages)
- [ ] Validate terminology loading

### Phase 9: Documentation & Release
- [ ] Update README.md (explain 2.0.0 changes)
- [ ] Update CHANGELOG.md
- [ ] Create MIGRATION_GUIDE.md (1.x → 2.0)
- [ ] Commit and create v2.0.0 tag

## Alternatives Considered

### Alternative 1: Keep AGENTS.md Monolithic

**Description**: Don't split into modules, keep everything in AGENTS.md

**Rejected because**:
- File already 1,441 lines, adding 31 modules would make it 5,000+ lines
- AI loads entire file every session (token waste)
- Difficult to maintain (all changes in single file)
- No project-type adaptation

### Alternative 2: Tool-Specific Configs (Not Universal)

**Description**: Use `.claude/`, `.cursor/`, `.opencode/` like everything-claude-code

**Rejected because**:
- Creates maintenance burden (sync 3+ configs)
- Not all tools support all directories
- `.scaffolding/` conveys "framework" better than tool names

### Alternative 3: Hardcoded Module Loading (Not Config-Driven)

**Description**: AI decides which modules to load based on keywords, no config.toml

**Rejected because**:
- Less predictable (AI might miss or over-load)
- Users have no control
- Can't explicitly disable unwanted modules
- No project-type awareness

### Alternative 4: Single Multilingual PR Template (Not Separate Files)

**Description**: One template with sections for each language

**Rejected because**:
- GitHub doesn't support conditional sections
- Creates clutter (users see all languages)
- Harder to maintain

## Notes

### MECE Verification

All 31 modules were classified using MECE principle:
- **Mutually Exclusive**: No content overlap between modules
- **Collectively Exhaustive**: Covers all IT team scenarios (software dev, academic, documentation)

Categories:
- Core (5) - Process fundamentals
- Software Development (6) - Tech stack specific
- Academic & Documentation (6) - Non-code work
- Feature (4) - Functional capabilities
- Quality (4) - Non-functional requirements
- Collaboration (4) - Team processes
- Scaffolding (2) - Meta (scaffolding itself)

### Future Considerations

**Potential additions**:
- Mobile app modules (React Native, Flutter)
- Embedded systems modules (Arduino, ESP32)
- Data science modules (Jupyter, R, Python scientific stack)
- Game development modules (Unity, Unreal)
- Blockchain modules (Solidity, Web3)

**Module format evolution**:
- Standardize module frontmatter (YAML)
- Add version numbers to modules
- Create module dependency graph
- Support module plugins (users can publish modules)

## References

- **ADR 0011**: Scaffolding Directory Naming and Skill Loading Priority
- **everything-claude-code**: https://github.com/affaan-m/everything-claude-code
- **Librarian session**: `ses_31e649d41ffewteyw2CKDwVXLE` (industry naming conventions)
- **Explore session**: `ses_31e6818d1ffeQLopMO9Upobh5s` (architecture analysis)
- **User conversation**: 2026-03-16 decision discussion
