# SCAFFOLDING_DEV_GUIDE

**Status**: Active | Domain: Scaffolding  
**Related Modules**: MODE_GUIDE, README_STRUCTURE, RELEASE_PROCESS

## Purpose

This module provides guidance for developing and extending the my-vibe-scaffolding template itself. Use this module when contributing to the scaffolding framework, adding new features, or creating custom templates.

## When to Use This Module

Reference this module when:
- Contributing to my-vibe-scaffolding
- Adding new scripts or tools
- Extending module system
- Creating custom scaffolding variants
- Debugging scaffolding issues
- Understanding template architecture

## Scaffolding Architecture

### Directory Structure

```
my-vibe-scaffolding/
├── .scaffolding/          # Template core (committed to Git)
│   ├── docs/              # Module documentation
│   ├── scripts/           # Automation scripts
│   ├── assets/            # Images, templates
│   ├── VERSION            # Template version
│   └── CHANGELOG.md       # Template changelog
│
├── .agents/               # AI agent configuration
│   ├── skills/            # Project-specific skills
│   ├── bundles.yaml       # Skill collections
│   └── workflows.yaml     # Playbooks
│
├── docs/                  # Project documentation (user-facing)
│   └── adr/               # Architecture decision records
│
├── config.toml            # Project configuration (gitignored)
├── VERSION                # Project version
├── CHANGELOG.md           # Project changelog
├── AGENTS.md              # AI agent instructions
└── README.md              # Project README
```

### File Ownership

| Path | Owner | Purpose |
|------|-------|---------|
| `.scaffolding/*` | Template | Framework files |
| `docs/`, `scripts/`, `assets/` | Project | Project-specific files |
| `config.toml` | User | Local configuration |
| `AGENTS.md` | Template | AI agent instructions |

## Development Setup

### Prerequisites

```bash
# Required tools
- Git 2.30+
- Bash 4.0+
- Node.js 18+ (if using npm scripts)
```

### Local Development

```bash
# Clone repository
git clone https://github.com/your-username/my-vibe-scaffolding.git
cd my-vibe-scaffolding

# Set mode to scaffolding
cat > config.toml << EOF
[project]
mode = "scaffolding"
type = "software"

[i18n]
primary_locale = "en-US"
fallback_locale = "en-US"
EOF

# Initialize (creates VERSION, hooks, etc.)
./.scaffolding/scripts/init-project.sh

# Verify setup
./.scaffolding/scripts/verify-setup.sh
```

## Adding New Modules

### 1. Create Module File

```bash
# Create new module
cat > .scaffolding/docs/NEW_MODULE.md << 'EOF'
# NEW_MODULE

**Status**: Active | Domain: Feature  
**Related Modules**: OTHER_MODULE

## Purpose

[Module purpose]

## When to Use This Module

- [Use case 1]
- [Use case 2]

## [Content sections...]
EOF
```

### 2. Update Module Registry

Edit `docs/adr/0012-module-system-and-conditional-loading.md`:

```markdown
## 3.2 Complete Module List

### Domain: Feature (Priority: High)
- ✅ AUTH_IMPLEMENTATION
- ✅ NEW_MODULE  <!-- Add here -->
```

### 3. Update config.toml.example

```toml
[modules]
# Add to appropriate section
feature_modules = ["auth_implementation", "new_module"]
```

### 4. Update AGENTS.md

Add to Module Loading Protocol:

```markdown
| NEW_MODULE | `features` contains `"new_feature"` | new, feature | `.scaffolding/docs/NEW_MODULE.md` |
```

### 5. Test Module Loading

```bash
# Set feature flag
cat >> config.toml << EOF
[project]
features = ["new_feature"]
EOF

# Verify module loads in AGENTS.md
```

## Adding New Scripts

### Script Template

```bash
#!/bin/bash
# .scaffolding/scripts/new-script.sh
# Purpose: [Brief description]
# Usage: ./new-script.sh [args]

set -e  # Exit on error
set -u  # Error on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Main logic
main() {
  log_info "Starting new script..."
  
  # Your code here
  
  log_info "✅ Script completed successfully"
}

# Run main
main "$@"
```

### Script Guidelines

- **Idempotent**: Safe to run multiple times
- **Error handling**: Use `set -e` and check exit codes
- **User feedback**: Clear progress messages
- **Documentation**: Usage comment at top
- **Testing**: Test on fresh clone

## Version Management

### Bumping Version

```bash
# Patch release (1.0.0 → 1.0.1)
./.scaffolding/scripts/bump-version.sh patch

# Minor release (1.0.0 → 1.1.0)
./.scaffolding/scripts/bump-version.sh minor

# Major release (1.0.0 → 2.0.0)
./.scaffolding/scripts/bump-version.sh major
```

### What bump-version.sh Does

1. Updates `.scaffolding/VERSION`
2. Updates `VERSION` (project copy)
3. Updates `.scaffolding/CHANGELOG.md`
4. Updates `CHANGELOG.md` (if exists)
5. Updates README badges
6. Creates git commit
7. Creates git tag

### Manual Version Update

If you need to update manually:

```bash
# 1. Update version files
echo "2.0.0" > .scaffolding/VERSION
echo "2.0.0" > VERSION

# 2. Update CHANGELOG.md
cat >> .scaffolding/CHANGELOG.md << 'EOF'
## [2.0.0] - 2024-01-15

### Added
- Major new feature

### Breaking Changes
- API change details
EOF

# 3. Commit and tag
git add .scaffolding/VERSION VERSION .scaffolding/CHANGELOG.md
git commit -m "chore: release v2.0.0"
git tag -a "v2.0.0" -m "Release v2.0.0"

# 4. Push
git push && git push --tags
```

## Testing Changes

### Test in Fresh Project

```bash
# 1. Create test directory
mkdir ~/test-scaffolding
cd ~/test-scaffolding

# 2. Copy scaffolding
cp -r /path/to/my-vibe-scaffolding/.scaffolding .
cp /path/to/my-vibe-scaffolding/config.toml.example config.toml

# 3. Initialize
./.scaffolding/scripts/init-project.sh

# 4. Verify
./.scaffolding/scripts/verify-setup.sh
```

### Automated Tests

```bash
# Run tests (if test suite exists)
npm test

# Lint scripts
shellcheck .scaffolding/scripts/*.sh

# Verify TOML syntax
toml-lint config.toml.example
```

## Contributing Guidelines

### Pull Request Process

1. Fork repository
2. Create feature branch
3. Make changes
4. Update documentation
5. Add tests (if applicable)
6. Update CHANGELOG.md
7. Create Pull Request

### Commit Convention

Follow Conventional Commits:

```
feat(scripts): add new initialization script
fix(modules): correct module loading logic
docs(guide): update scaffolding dev guide
chore(deps): update dependencies
```

### Code Review Checklist

- [ ] Changes tested in fresh project
- [ ] Documentation updated
- [ ] CHANGELOG.md entry added
- [ ] No breaking changes (or clearly documented)
- [ ] Scripts have proper error handling
- [ ] All checks passing

## Common Development Tasks

### Adding New Language Support

1. Create locale files:
   ```bash
   mkdir -p i18n/locales/ja-JP
   cp i18n/locales/en-US/* i18n/locales/ja-JP/
   ```

2. Translate content:
   ```bash
   # Edit ja-JP TOML files
   vim i18n/locales/ja-JP/agents.toml
   vim i18n/locales/ja-JP/readme.toml
   ```

3. Update generate-readme.sh to handle new locale

4. Test generation:
   ```bash
   ./.scaffolding/scripts/generate-readme.sh
   ```

### Creating Custom Skill

1. Create skill file:
   ```bash
   mkdir -p .agents/skills/my-skill
   cat > .agents/skills/my-skill/SKILL.md << 'EOF'
   ---
   name: my-skill
   version: 1.0.0
   description: Custom skill for my project
   tags: [custom, project-specific]
   ---

   # My Custom Skill

   [Skill content...]
   EOF
   ```

2. Register in bundles.yaml:
   ```yaml
   my-bundle:
     description: My custom bundle
     skills:
       - my-skill
   ```

3. Test loading:
   ```
   @use my-skill
   ```

## Troubleshooting Development

### Script Fails with "Command not found"

Check system detection:

```bash
./.scaffolding/scripts/detect-os.sh
cat config.toml | grep '\[system\]' -A 20
```

### Module Not Loading

Verify config.toml settings:

```bash
# Check project type
grep 'type = ' config.toml

# Check feature flags
grep 'features = ' config.toml

# Check module overrides
grep 'manual_enabled = ' config.toml
```

### Version Mismatch

Sync versions:

```bash
./.scaffolding/scripts/check-version-sync.sh
```

## Related Modules

- **MODE_GUIDE** - Understanding scaffolding modes
- **README_STRUCTURE** - Documentation standards
- **RELEASE_PROCESS** - Version and release management
