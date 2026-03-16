# MODE_GUIDE

**Status**: Active | Domain: Scaffolding  
**Related Modules**: SCAFFOLDING_DEV_GUIDE, README_STRUCTURE

## Purpose

This module explains the different working modes of my-vibe-scaffolding template. It covers scaffolding mode (developing the template itself) and project mode (using the template for your project).

## When to Use This Module

Reference this module when:
- Starting a new project with this template
- Contributing to template development
- Understanding file organization
- Deciding where to place new files
- Configuring the template for your use case

## Mode Overview

The scaffolding has **two primary modes** configured in `config.toml`:

### Scaffolding Mode (`mode = "scaffolding"`)

**Purpose**: Developing the my-vibe-scaffolding template itself.

**Use when**:
- Contributing to the template repository
- Adding new features to the scaffolding
- Updating template documentation
- Creating new scripts or tools

**File organization**:
- **ADRs**: `.scaffolding/docs/adr/`
- **Scripts**: `.scaffolding/scripts/`
- **Assets**: `.scaffolding/assets/`
- **Root directories**: Minimal or empty (`docs/`, `scripts/`, `assets/`)

**README behavior** (if `sync_readme = true`):
- Root `README*.md` files auto-sync to `.scaffolding/README*.md`
- Both copies stay identical

### Project Mode (`mode = "project"`)

**Purpose**: Using the template for your own project.

**Use when**:
- Building your application
- Customizing for your project needs
- Creating project-specific documentation

**File organization**:
- **ADRs**: `docs/adr/`
- **Scripts**: `scripts/`
- **Assets**: `assets/`
- **`.scaffolding/` directory**: Reference examples only (don't modify)

**README behavior**:
- Root `README.md` is your project documentation
- Independent from `.scaffolding/README.md`

## Configuration

### Setting Mode

Edit `config.toml`:

```toml
[project]
mode = "scaffolding"  # or "project"
type = "fullstack"    # frontend | backend | fullstack | cli | library | academic
```

### Mode Detection

Scripts automatically detect mode:

```bash
# In scripts
MODE=$(grep '^mode = ' config.toml | cut -d '"' -f 2)

if [ "$MODE" = "scaffolding" ]; then
  # Scaffolding-specific logic
else
  # Project-specific logic
fi
```

## Mode Comparison

| Aspect | Scaffolding Mode | Project Mode |
|--------|------------------|--------------|
| **ADRs** | `.scaffolding/docs/adr/` | `docs/adr/` |
| **Scripts** | `.scaffolding/scripts/` | `scripts/` |
| **Assets** | `.scaffolding/assets/` | `assets/` |
| **VERSION** | `.scaffolding/VERSION` | `VERSION` |
| **CHANGELOG** | `.scaffolding/CHANGELOG.md` | `CHANGELOG.md` |
| **README** | Synced (if enabled) | Independent |
| **Purpose** | Template development | Project development |

## Workflow Examples

### Scaffolding Mode Workflow

**Scenario**: Adding a new script to the template

```bash
# 1. Ensure scaffolding mode
grep 'mode = "scaffolding"' config.toml

# 2. Create script in template directory
cat > .scaffolding/scripts/new-feature.sh << 'EOF'
#!/bin/bash
# New feature script
EOF

chmod +x .scaffolding/scripts/new-feature.sh

# 3. Test script
./.scaffolding/scripts/new-feature.sh

# 4. Update documentation
vim .scaffolding/docs/SCAFFOLDING_DEV_GUIDE.md

# 5. Update changelog
cat >> .scaffolding/CHANGELOG.md << 'EOF'
### Added
- New feature script for X
EOF

# 6. Commit to template repository
git add .scaffolding/
git commit -m "feat(scripts): add new feature script"
git push
```

### Project Mode Workflow

**Scenario**: Creating project-specific script

```bash
# 1. Ensure project mode
grep 'mode = "project"' config.toml

# 2. Create script in project directory
mkdir -p scripts
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
# Project-specific deployment script
EOF

chmod +x scripts/deploy.sh

# 3. Test script
./scripts/deploy.sh

# 4. Document in project README
vim README.md

# 5. Commit to project repository
git add scripts/deploy.sh README.md
git commit -m "feat: add deployment script"
git push
```

## File Placement Decision Tree

```
New file needed?
│
├─ Is it template infrastructure?
│  ├─ Yes → .scaffolding/
│  │   └─ Example: New module, core script
│  └─ No → Continue
│
├─ Is it project-specific?
│  ├─ Yes → Root directories (docs/, scripts/, assets/)
│  │   └─ Example: API docs, deploy script, logo
│  └─ No → Continue
│
└─ Is it AI agent configuration?
   ├─ Yes → .agents/
   │   └─ Example: Custom skills, bundles
   └─ No → Reconsider if file is needed
```

## AI Agent Behavior by Mode

### Scaffolding Mode

AI agents will:
- Create ADRs in `.scaffolding/docs/adr/`
- Reference scripts from `.scaffolding/scripts/`
- Place assets in `.scaffolding/assets/`
- Generate bilingual README following template format
- Update `.scaffolding/CHANGELOG.md` for template changes

### Project Mode

AI agents will:
- Create ADRs in `docs/adr/`
- Place scripts in `scripts/`
- Place assets in `assets/`
- Edit root `README.md` for your project
- Update root `CHANGELOG.md` for project changes
- Reference `.scaffolding/` examples but not modify them

## Switching Modes

### From Project to Scaffolding

**Reason**: Contributing a feature back to template

```bash
# 1. Change mode
sed -i 's/mode = "project"/mode = "scaffolding"/' config.toml

# 2. Move files to template directories
mv docs/new-feature.md .scaffolding/docs/
mv scripts/new-script.sh .scaffolding/scripts/

# 3. Update documentation
vim .scaffolding/CHANGELOG.md

# 4. Test
./.scaffolding/scripts/verify-setup.sh

# 5. Commit
git add config.toml .scaffolding/
git commit -m "feat: add new feature to template"
```

### From Scaffolding to Project

**Reason**: Finished template development, starting project

```bash
# 1. Change mode
sed -i 's/mode = "scaffolding"/mode = "project"/' config.toml

# 2. Initialize project
./.scaffolding/scripts/init-project.sh

# 3. Customize project README
vim README.md

# 4. Start building your project
# Project files go in root docs/, scripts/, assets/
```

## Common Scenarios

### Scenario 1: Template Contributor

**Mode**: `scaffolding`

You're improving the template for everyone:

```bash
# Work in .scaffolding/
.scaffolding/
├── docs/          # Add modules here
├── scripts/       # Add scripts here
└── assets/        # Add images here

# Root stays minimal
docs/              # Empty or template examples
scripts/           # Empty or template examples
```

### Scenario 2: Project Developer

**Mode**: `project`

You're building your application:

```bash
# Work in root
docs/              # Your project docs
scripts/           # Your project scripts
assets/            # Your project assets

# .scaffolding/ is reference only
.scaffolding/      # Don't modify (reference only)
```

### Scenario 3: Hybrid (Advanced)

**Mode**: `project` with custom template extensions

You're using the template but also extending it:

```bash
# Project files
docs/              # Project-specific docs
scripts/           # Project scripts

# Custom template extensions
.agents/skills/    # Custom skills (not in .scaffolding)
```

## Best Practices

### DO ✅

- **Check mode before creating files** - Prevents misplaced files
- **Use init-project.sh after cloning** - Sets up mode correctly
- **Document mode in project README** - Help team understand structure
- **Switch modes consciously** - Understand implications

### DON'T ❌

- **Mix modes without clear reason** - Causes confusion
- **Modify .scaffolding/ in project mode** - Breaks updates
- **Forget to commit config.toml** - Mode should be tracked
- **Ignore mode in scripts** - Scripts should respect mode

## Troubleshooting

### "Files in wrong directory"

**Symptom**: ADRs in root but mode is scaffolding

**Solution**:
```bash
# Check mode
grep '^mode = ' config.toml

# Move files to correct location
mv docs/adr/* .scaffolding/docs/adr/
```

### "Template updates conflict with project files"

**Symptom**: Git conflicts in `.scaffolding/` after pulling template updates

**Solution**:
```bash
# If in project mode, .scaffolding/ should not have local changes
git checkout --theirs .scaffolding/

# Or discard local changes
git restore .scaffolding/
```

### "Mode setting ignored"

**Symptom**: Scripts don't respect mode

**Solution**:
```bash
# Verify config.toml format
cat config.toml | grep '\[project\]' -A 5

# Should see:
# [project]
# mode = "project"  # or "scaffolding"

# Re-run detection
./.scaffolding/scripts/detect-os.sh
```

## Related Modules

- **SCAFFOLDING_DEV_GUIDE** - Template development
- **README_STRUCTURE** - Documentation standards
- **ONBOARDING_GUIDE** - Team onboarding
