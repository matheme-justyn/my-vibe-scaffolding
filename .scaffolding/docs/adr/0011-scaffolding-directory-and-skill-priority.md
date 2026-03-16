# ADR 0011: Scaffolding Directory Naming and Skill Loading Priority

## Status

Accepted

## Date

2026-03-16

## Context

### Background

After integrating everything-claude-code's five-layer architecture (agents/skills/commands/rules/agentshield) in v1.15.0, we faced a critical naming decision: how to organize AI configuration files in a **project scaffolding template** that supports multiple AI tools (OpenCode, Cursor, Windsurf, Claude).

The existing structure used `.agents/` at root level, but this raised questions:
- Is `.agents/` the right name for a scaffolding template?
- Should AI configs be nested inside the scaffolding framework directory?
- What happens when users create their own `.agents/` directory?

### Research Findings

We analyzed three sources:

1. **everything-claude-code** (Anthropic Hackathon Winner):
   - Uses **multiple tool-specific directories** (.claude/, .cursor/, .opencode/, .codex/)
   - Also has **generic directories** (.agents/, agents/, skills/, commands/) at root level
   - Separates AI configs (dot directories) from human docs (docs/)

2. **Industry trends** (via librarian search):
   - **`.agents/` is becoming the cross-tool standard**
   - Microsoft VSCode: Adding `.agents/skills` to default folder list
   - Qwen Code: Already loads skills from `.agents/`
   - agents.md proposal (19K stars): Advocating for `.agent/` or `.agents/` as standard

3. **User needs** (scaffolding semantics):
   - Current `.scaffolding/` name is ambiguous (conflicts with "template files" like .ejs, .hbs)
   - Need clear distinction between "scaffolding framework" vs "AI configs" vs "project content"
   - Want users to be able to customize skills without breaking scaffolding defaults

### The Core Problem

When users create projects from this scaffolding template:
- **Scaffolding provides** curated, high-quality agents/skills (best practices)
- **Users may want to** add custom skills or override defaults
- **Conflict scenario**: What happens when `.scaffolding/skills/brainstorming/` and `.agents/skills/brainstorming/` both exist?

## Decision

### Directory Structure

Rename `.scaffolding/` → `.scaffolding/` and nest AI configs inside:

```
my-vibe-scaffolding/
├── .scaffolding/              # Scaffolding framework (renamed from .template)
│   ├── agents/                # Scaffolding-provided agents
│   ├── skills/                # Scaffolding-provided skills
│   ├── commands/              # Scaffolding-provided commands
│   ├── rules/                 # Scaffolding-provided rules
│   ├── agentshield/           # Security framework
│   ├── docs/                  # Scaffolding documentation
│   ├── scripts/               # Scaffolding utilities
│   └── i18n/                  # Internationalization
│
├── .agents/                   # User customizations (optional)
│   ├── skills/                # User-defined skills
│   ├── agents/                # User-defined agents
│   └── ...
│
├── AGENTS.md                  # AI orchestration config
└── docs/                      # Project human docs
```

### Skill Loading Priority (Merge Mode)

**Strategy**: Scaffolding provides baseline + users can extend/override

**Priority order**:
```
Priority 1 (Lowest):  ~/.config/opencode/skills/     # Global user skills
Priority 2 (Medium):  .scaffolding/skills/           # Scaffolding defaults
Priority 3 (Highest): .agents/skills/                # Project customizations
```

**Conflict resolution**:
- **Same skill name** → User version wins (Priority 3 > Priority 2)
- **Different names** → All skills load (merged)
- **Rationale**: Users explicitly adding a skill should override scaffolding defaults

### Updated AGENTS.md Section

```markdown
## Skill System

### Skill Discovery Paths

Skills are loaded with **user-first priority** to allow customization:

```
Priority 3 (Highest): .agents/skills/                # Project customizations
Priority 2 (Medium):  .scaffolding/skills/           # Scaffolding defaults
Priority 1 (Lowest):  ~/.config/opencode/skills/     # Global user skills
```

**Merge Strategy:**
- Scaffolding provides curated best-practice skills
- Users can extend with custom skills (different names)
- Users can override scaffolding skills (same names → user wins)

**Example:**
```
.scaffolding/skills/brainstorming/     # Scaffolding default
.agents/skills/brainstorming/          # User override ✅ (this one loads)
.agents/skills/my-custom-skill/        # User extension ✅ (also loads)
```

**Why This Design:**
- ✅ Scaffolding provides "default best practices"
- ✅ Users can "extend without breaking"
- ✅ Users can "override when they know better"
- ✅ Clear semantics: `.agents/` = project-level customization
```

## Rationale

### Why `.scaffolding/` (not `.scaffolding/`)

| Reason | Explanation |
|--------|-------------|
| **Semantic precision** | "Scaffolding" clearly means "project framework", while "template" is ambiguous (template files? template repository?) |
| **Professional terminology** | Industry uses "scaffolding" for project setup frameworks (Yeoman, create-react-app, etc.) |
| **Avoid confusion** | `.scaffolding/` conflicts with templating tools (.ejs, .hbs, .mustache) |
| **Intent clarity** | Users immediately understand this is the framework infrastructure |

### Why Nest agents/ Inside `.scaffolding/`

| Reason | Explanation |
|--------|-------------|
| **Logical grouping** | AI configs are part of the scaffolding framework, not project content |
| **Clear ownership** | `.scaffolding/` = "provided by template", `.agents/` = "customized by user" |
| **Upgrade path** | When scaffolding updates, `.scaffolding/` updates cleanly without touching `.agents/` |
| **Avoid root clutter** | Keeps root directory clean (only `.agents/` if user customizes) |

### Why User Priority (Not Scaffolding Priority)

| Reason | Explanation |
|--------|-------------|
| **User intent** | If user explicitly creates `.agents/skills/X/`, they want to use their version |
| **Override flexibility** | Users may need project-specific variations of scaffolding skills |
| **Non-breaking** | Users who don't customize get scaffolding defaults automatically |
| **Upgrade safety** | Scaffolding updates won't break user customizations |

### Why Merge Mode (Not Isolation)

| Reason | Explanation |
|--------|-------------|
| **Best of both worlds** | Scaffolding provides baseline, users extend as needed |
| **Gradual customization** | Users start with scaffolding skills, customize incrementally |
| **No lock-in** | Users can override any skill without losing others |
| **Discoverability** | Users see scaffolding skills, can copy-modify as starting point |

## Consequences

### Positive

- ✅ **Clear semantics**: `.scaffolding/` clearly indicates framework code
- ✅ **User empowerment**: Users can customize anything they need
- ✅ **Upgrade safety**: Scaffolding updates don't break user customizations
- ✅ **Non-breaking defaults**: Users who don't customize get quality defaults
- ✅ **Flexible extension**: Users can add new skills without touching scaffolding

### Negative

- ❌ **Breaking change**: Requires renaming `.scaffolding/` → `.scaffolding/` (one-time migration)
- ❌ **Documentation updates**: All docs referencing `.scaffolding/` need updates
- ❌ **Script updates**: Shell scripts, git hooks, CI/CD need path updates
- ❌ **Potential confusion**: Users might not understand priority order initially

### Migration Required

1. **Directory rename**:
   ```bash
   mv .template .scaffolding
   ```

2. **Update references** in:
   - All `*.md` files (AGENTS.md, README.md, ADRs)
   - All scripts in `.scaffolding/scripts/`
   - Git hooks
   - `config.toml` paths
   - CI/CD workflows (if any)

3. **Update AGENTS.md**:
   - Skill Discovery Paths section
   - All directory references

4. **Version bump**: Major version (2.0.0) due to breaking directory structure change

## Alternatives Considered

### Alternative 1: Keep `.agents/` at Root

```
.agents/              # AI configs (root level)
.scaffolding/            # Scaffolding (unchanged)
```

**Rejected because**:
- Doesn't clarify ownership (scaffolding vs user)
- Misses semantic improvement opportunity (`.scaffolding/` ambiguity)
- Follows tool-specific naming (`.agents/` suggests generic, but located in framework)

### Alternative 2: Use `.scaffolding/agents/` (No Rename)

```
.scaffolding/
├── agents/
├── skills/
└── ...
```

**Rejected because**:
- `.scaffolding/` remains semantically ambiguous
- Doesn't fix "template files" confusion

### Alternative 3: Scaffolding Priority (Not User Priority)

```
Priority: .scaffolding/skills/ > .agents/skills/
```

**Rejected because**:
- Prevents users from overriding scaffolding decisions
- Creates frustration when users need project-specific customization
- Violates principle of "user intent should win"

## Notes

### Industry Alignment

While `.agents/` is becoming a cross-tool standard for **root-level user configs**, our use case is different:
- We're a **scaffolding template**, not an end-user project
- We need to distinguish "scaffolding-provided" vs "user-customized"
- Nesting inside `.scaffolding/` achieves this while still supporting `.agents/` for user overrides

### Tool Compatibility

AI tools (OpenCode, Cursor, Windsurf) typically look for:
1. Root-level `.agents/` (user configs)
2. Tool-specific directories (`.opencode/`, `.cursor/`)

Our structure supports both:
- `.scaffolding/` for framework (not tool-parsed)
- `.agents/` for user overrides (tool-parsed if exists)

### Future Considerations

- **Tool evolution**: If tools start hardcoding `.scaffolding/` paths, we may need to adapt
- **Symlinks**: Could symlink `.agents/` → `.scaffolding/agents/` if tools require root-level paths
- **Documentation**: Must clearly explain priority system to users

## References

- **everything-claude-code**: https://github.com/affaan-m/everything-claude-code
- **agents.md proposal**: https://github.com/agentsmd/agents.md
- **Librarian research**: Session `ses_31e649d41ffewteyw2CKDwVXLE`
- **Explore research**: Session `ses_31e6818d1ffeQLopMO9Upobh5s`
