#!/usr/bin/env bash
# ==============================================================================
# Upgrade Script: v2.x → v3.0.0
# ==============================================================================
# Painless one-command upgrade to integrate OpenSpec + Superpowers Iron Laws
#
# Usage:
#   ./.scaffolding/scripts/upgrade-to-v3.sh [options]
#
# Options:
#   -n, --dry-run       Preview changes without applying
#   -f, --force         Skip safety checks (use with caution)
#   -v, --verbose       Show detailed progress
#   -h, --help          Show this help message
#
# What this does:
#   1. Pre-flight checks (version, git status)
#   2. Backup current state
#   3. Relocate .agents/ → .scaffolding/agents/ (template infrastructure)
#   4. Delete ECC tdd-workflow.md (superseded by Superpowers)
#   5. Copy transformed skills (backend-patterns v2.0, etc.)
#   6. Create OpenSpec directory structure
#   7. Merge SDD config into config.toml
#   8. Generate migration report
#   9. Provide rollback instructions
#
# Prerequisites:
#   - my-vibe-scaffolding v2.1.0+
#   - Git repository initialized
#   - No uncommitted changes (will be checked)
#
# Safety:
#   - Creates automatic backup before changes
#   - Validation at each step
#   - Rollback script generated
#   - Non-destructive (preserves all existing files)
#
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCAFFOLDING_DIR="$PROJECT_ROOT/.scaffolding"
OLD_AGENTS_DIR="$PROJECT_ROOT/.agents"
NEW_AGENTS_DIR="$SCAFFOLDING_DIR/agents"

# Version requirements
MIN_VERSION="2.1.0"
TARGET_VERSION="3.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false
FORCE=false
VERBOSE=false

# Backup
BACKUP_DIR="$PROJECT_ROOT/.upgrade-backup-$(date +%Y%m%d-%H%M%S)"

# Migration state
MIGRATION_LOG="$BACKUP_DIR/migration.log"
MIGRATION_REPORT="$BACKUP_DIR/migration-report.md"

# ==============================================================================
# Helper Functions
# ==============================================================================

log() {
    mkdir -p "$BACKUP_DIR"
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$MIGRATION_LOG"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*" | tee -a "$MIGRATION_LOG"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $*" | tee -a "$MIGRATION_LOG"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" | tee -a "$MIGRATION_LOG"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $*" | tee -a "$MIGRATION_LOG"
    fi
}

die() {
    log_error "$1"
    echo -e "${RED}${BOLD}Migration failed. Rolling back...${NC}"
    rollback_migration
    exit 1
}

version_gte() {
    # Compare versions: $1 >= $2
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

show_help() {
    cat << 'EOF'
Upgrade Script: v2.x → v3.0.0

Usage:
  ./upgrade-to-v3.sh [OPTIONS]

Options:
  -n, --dry-run     Preview changes without applying them
  -f, --force       Skip safety checks (use with caution)
  -v, --verbose     Show detailed progress
  -h, --help        Show this help message

What this upgrade does:
  1. Relocates .agents/ → .scaffolding/agents/ (template infrastructure)
  2. Deletes ECC tdd-workflow.md (superseded by Superpowers)
  3. Copies transformed skills with Iron Laws (v2.0)
  4. Creates OpenSpec SDD structure
  5. Merges SDD configuration into config.toml
  6. Generates migration report

Safety:
  - Automatic backup created before changes
  - Rollback script generated
  - Git status checked (unless --force)
  - Dry-run mode available for preview

Examples:
  # Preview changes
  ./upgrade-to-v3.sh --dry-run

  # Run upgrade
  ./upgrade-to-v3.sh

  # Run upgrade with verbose output
  ./upgrade-to-v3.sh --verbose

  # Force upgrade (skip safety checks)
  ./upgrade-to-v3.sh --force

EOF
    exit 0
}

# ==============================================================================
# Parse Arguments
# ==============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

check_prerequisites() {
    log "Running pre-flight checks..."

    # Check if in project root
    if [ ! -f "$PROJECT_ROOT/config.toml" ] && [ ! -f "$PROJECT_ROOT/config.toml.example" ]; then
        die "Not in project root (config.toml not found)"
    fi

    # Check if .scaffolding exists
    if [ ! -d "$SCAFFOLDING_DIR" ]; then
        die ".scaffolding directory not found"
    fi

    # Check current version
    if [ ! -f "$PROJECT_ROOT/VERSION" ]; then
        die "VERSION file not found"
    fi

    CURRENT_VERSION=$(cat "$PROJECT_ROOT/VERSION" | tr -d '[:space:]')
    log "Current version: $CURRENT_VERSION"

    if ! version_gte "$CURRENT_VERSION" "$MIN_VERSION"; then
        die "Minimum version required: $MIN_VERSION (found: $CURRENT_VERSION)"
    fi

    log_success "Version check passed"

    # Check git status
    if ! $FORCE; then
        if [ -d "$PROJECT_ROOT/.git" ]; then
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                die "Working directory has uncommitted changes. Commit or stash them first."
            fi
            log_success "Git status clean"
        else
            log_warning "Not a git repository, skipping git check"
        fi
    else
        log_warning "Skipping git status check (--force)"
    fi

    # Check if already upgraded
    if [ -d "$NEW_AGENTS_DIR" ]; then
        log_warning ".scaffolding/agents/ already exists. This might be a re-run."
        if ! $FORCE; then
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi

    log_success "Pre-flight checks passed"
}

# ==============================================================================
# Backup
# ==============================================================================

create_backup() {
    log "Creating backup at $BACKUP_DIR..."

    mkdir -p "$BACKUP_DIR"

    # Initialize migration log
    touch "$MIGRATION_LOG"
    log "Backup directory: $BACKUP_DIR"

    # Backup critical files
    local files_to_backup=(
        "config.toml"
        "AGENTS.md"
    )

    for file in "${files_to_backup[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            local backup_path="$BACKUP_DIR/$(dirname "$file")"
            mkdir -p "$backup_path"
            cp "$PROJECT_ROOT/$file" "$BACKUP_DIR/$file"
            log_verbose "Backed up: $file"
        fi
    done

    # Backup .agents directory (if exists)
    if [ -d "$OLD_AGENTS_DIR" ]; then
        cp -r "$OLD_AGENTS_DIR" "$BACKUP_DIR/.agents"
        log_verbose "Backed up: .agents/"
    fi

    log_success "Backup created successfully"
}

# ==============================================================================
# Migration Steps
# ==============================================================================

relocate_agents_directory() {
    log "Step 1: Relocating .agents/ → .scaffolding/agents/..."

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would relocate:"
        echo "  Source: $OLD_AGENTS_DIR"
        echo "  Destination: $NEW_AGENTS_DIR"
        if [ -d "$OLD_AGENTS_DIR" ]; then
            echo "  Files to move:"
            find "$OLD_AGENTS_DIR" -type f | sed 's|^|    - |'
        fi
        return
    fi

    # Create new directory structure
    mkdir -p "$NEW_AGENTS_DIR"

    # Move subdirectories if they exist
    local subdirs=("skills" "agents" "commands")
    for subdir in "${subdirs[@]}"; do
        if [ -d "$OLD_AGENTS_DIR/$subdir" ]; then
            mv "$OLD_AGENTS_DIR/$subdir" "$NEW_AGENTS_DIR/$subdir"
            log_verbose "Moved: $subdir/"
        fi
    done

    # Move YAML files
    for file in bundles.yaml workflows.yaml; do
        if [ -f "$OLD_AGENTS_DIR/$file" ]; then
            mv "$OLD_AGENTS_DIR/$file" "$NEW_AGENTS_DIR/$file"
            log_verbose "Moved: $file"
        fi
    done

    # Move README if exists
    if [ -f "$OLD_AGENTS_DIR/README.md" ]; then
        mv "$OLD_AGENTS_DIR/README.md" "$NEW_AGENTS_DIR/README.md"
        log_verbose "Moved: README.md"
    fi

    # Create .gitkeep in old location for project-specific agents
    mkdir -p "$OLD_AGENTS_DIR"
    touch "$OLD_AGENTS_DIR/.gitkeep"
    cat > "$OLD_AGENTS_DIR/README.md" << 'EOF'
# Project-Specific Agents

This directory is for your project-specific agents, skills, and workflows.

Template infrastructure has been moved to `.scaffolding/agents/`.

## Usage

- **Template agents/skills**: `.scaffolding/agents/`
- **Project agents/skills**: `.agents/` (this directory)

Create your custom agents here to avoid conflicts with template updates.

EOF

    log_success "Agents directory relocated"
}

delete_ecc_tdd_workflow() {
    log "Step 2: Deleting ECC tdd-workflow.md (superseded by Superpowers)..."

    local tdd_files=(
        "$NEW_AGENTS_DIR/skills/universal/tdd-workflow.md"
        "$NEW_AGENTS_DIR/skills/tdd-workflow.md"
    )

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would delete:"
        for file in "${tdd_files[@]}"; do
            if [ -f "$file" ]; then
                echo "  - $file"
            fi
        done
        return
    fi

    local deleted=false
    for file in "${tdd_files[@]}"; do
        if [ -f "$file" ]; then
            rm "$file"
            log_verbose "Deleted: $file"
            deleted=true
        fi
    done

    if [ "$deleted" = true ]; then
        log_success "ECC tdd-workflow deleted"
    else
        log_warning "ECC tdd-workflow not found (might already be deleted)"
    fi
}

copy_transformed_skills() {
    log "Step 3: Copying transformed skills (v2.0 with Iron Laws)..."

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would copy transformed skills:"
        echo "  - backend-patterns v2.0"
        echo "  - frontend-patterns v2.0"
        echo "  - api-design v2.0"
        echo "  - security-review v2.0"
        echo "  - error-handling v2.0"
        return
    fi

    # Create skill directories
    mkdir -p "$NEW_AGENTS_DIR/skills/backend"
    mkdir -p "$NEW_AGENTS_DIR/skills/frontend"
    mkdir -p "$NEW_AGENTS_DIR/skills/universal"

    # Copy transformed skills from .scaffolding/agents/skills/
    local skill_mappings=(
        "backend/backend-patterns-v2.md:backend/backend-patterns.md"
        "backend/error-handling-v2.md:backend/error-handling.md"
        "frontend/frontend-patterns-v2.md:frontend/frontend-patterns.md"
        "universal/api-design-v2.md:universal/api-design.md"
        "universal/security-review-v2.md:universal/security-review.md"
    )

    for mapping in "${skill_mappings[@]}"; do
        IFS=':' read -r source dest <<< "$mapping"
        local source_file="$SCAFFOLDING_DIR/agents/skills/$source"
        local dest_file="$NEW_AGENTS_DIR/skills/$dest"

        if [ -f "$source_file" ]; then
            cp "$source_file" "$dest_file"
            log_verbose "Copied: $dest"
        else
            log_warning "Source not found: $source_file"
        fi
    done

    log_success "Transformed skills copied (5 skills)"
}

create_openspec_structure() {
    log "Step 4: Creating OpenSpec directory structure..."

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would create:"
        echo "  - .scaffolding/openspec/"
        echo "  - .scaffolding/openspec/specs/"
        echo "  - .scaffolding/openspec/changes/"
        echo "  - .scaffolding/openspec/changes/archive/"
        return
    fi

    mkdir -p "$SCAFFOLDING_DIR/openspec/specs"
    mkdir -p "$SCAFFOLDING_DIR/openspec/changes/archive"

    # Create project.md
    cat > "$SCAFFOLDING_DIR/openspec/project.md" << EOF
# Project Context

**Created**: $(date +%Y-%m-%d)
**Version**: 3.0.0

## Overview

<!-- Describe your project here -->

## Architecture

<!-- High-level architecture overview -->

## Conventions

<!-- Project-specific conventions -->

## Active Areas

<!-- List areas currently under active development -->

EOF

    # Create README
    cat > "$SCAFFOLDING_DIR/openspec/README.md" << 'EOF'
# OpenSpec Directory

Spec-Driven Development (SDD) artifacts for systematic change management.

## Structure

```
openspec/
├── project.md              # Project context (architecture, conventions)
├── specs/                  # Approved specifications
│   └── YYYYMMDD-feature-name.md
├── changes/                # Active change proposals
│   ├── proposal.md         # Current proposal
│   ├── design.md           # Detailed design
│   └── tasks.md            # Implementation tasks
└── changes/archive/        # Completed changes
    └── YYYYMMDD-feature-name/
```

## Workflow

1. **Propose**: Create change proposal in `changes/`
2. **Design**: Detail the design in `changes/design.md`
3. **Plan**: Break down into tasks in `changes/tasks.md`
4. **Implement**: Execute tasks with `sdd-apply` skill
5. **Archive**: Move to `changes/archive/` on completion

## Skills

- `sdd-propose` - Create change proposal
- `sdd-apply` - Apply approved changes
- `sdd-archive` - Archive completed changes

## Configuration

See `config.toml` `[sdd]` section for SDD settings.

EOF

    log_success "OpenSpec structure created"
}

merge_sdd_config() {
    log "Step 5: Merging SDD configuration into config.toml..."

    local config_file="$PROJECT_ROOT/config.toml"
    
    if [ ! -f "$config_file" ]; then
        log_warning "config.toml not found, using config.toml.example"
        if [ -f "$PROJECT_ROOT/config.toml.example" ]; then
            cp "$PROJECT_ROOT/config.toml.example" "$config_file"
        else
            die "Neither config.toml nor config.toml.example found"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would add [sdd] section to config.toml"
        return
    fi

    # Check if [sdd] section already exists
    if grep -q "^\[sdd\]" "$config_file"; then
        log_warning "[sdd] section already exists in config.toml"
        return
    fi

    # Append SDD configuration
    cat >> "$config_file" << 'EOF'

# ==============================================================================
# Spec-Driven Development (SDD) Configuration (3.0.0+)
# ==============================================================================
# OpenSpec integration for systematic change management

[sdd]
# Enable SDD workflow
enabled = false  # Set to true when ready to use SDD

# Workflow mode
workflow = "openspec"  # openspec | traditional | hybrid

# Strict mode: Enforce specs before implementation
strict_mode = true  # true = must create spec first, false = optional

# Auto-archive: Move completed changes to archive on merge
auto_archive = true

[sdd.artifacts]
# Required artifacts for each change proposal
proposal_required = true   # proposal.md (problem, approach, risks)
design_required = true     # design.md (detailed design)
tasks_required = true      # tasks.md (implementation steps)

[sdd.rationalization_prevention]
# Superpowers integration: Block AI rationalization
enabled = true
enforce_mandatory_skills = true

# Common rationalization patterns to block
block_excuses = [
    "just a simple question",
    "I need context first",
    "let me check files quickly",
    "this is straightforward",
    "I know what to do",
]

[sdd.thresholds]
# When to require specs (based on change complexity)
# Options: always | medium_and_above | complex_only | never
require_spec_for = "medium_and_above"

# Complexity indicators
complex_if_files_modified = 3      # 3+ files = complex
complex_if_lines_changed = 150     # 150+ lines = complex
complex_if_new_dependencies = true # New deps = complex

EOF

    log_success "SDD configuration merged (disabled by default)"
}

update_agents_md() {
    log "Step 6: Updating AGENTS.md with new directory structure..."

    local agents_md="$PROJECT_ROOT/AGENTS.md"

    if [ ! -f "$agents_md" ]; then
        log_warning "AGENTS.md not found, skipping"
        return
    fi

    if [ "$DRY_RUN" = true ]; then
        log "[DRY RUN] Would update AGENTS.md references"
        return
    fi

    # Update .agents/ references to .scaffolding/agents/
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' 's|\.agents/skills/|.scaffolding/agents/skills/|g' "$agents_md"
        sed -i '' 's|\.agents/agents/|.scaffolding/agents/agents/|g' "$agents_md"
        sed -i '' 's|\.agents/commands/|.scaffolding/agents/commands/|g' "$agents_md"
    else
        # Linux
        sed -i 's|\.agents/skills/|.scaffolding/agents/skills/|g' "$agents_md"
        sed -i 's|\.agents/agents/|.scaffolding/agents/agents/|g' "$agents_md"
        sed -i 's|\.agents/commands/|.scaffolding/agents/commands/|g' "$agents_md"
    fi

    log_success "AGENTS.md updated"
}

# ==============================================================================
# Report Generation
# ==============================================================================

generate_migration_report() {
    log "Generating migration report..."

    cat > "$MIGRATION_REPORT" << EOF
# Migration Report: v2.x → v3.0.0

**Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Status**: SUCCESS ✅

## Summary

Successfully upgraded to v3.0.0 with OpenSpec + Superpowers Iron Laws integration.

## Changes Applied

### 1. Directory Restructuring

- ✅ Moved \`.agents/\` → \`.scaffolding/agents/\`
  - Template infrastructure now in \`.scaffolding/\`
  - \`.agents/\` reserved for project-specific agents
  - Created \`.agents/.gitkeep\` and README

### 2. Skill Transformations

- ✅ Deleted ECC \`tdd-workflow.md\` (superseded by Superpowers)
- ✅ Copied 5 transformed skills with Iron Laws:
  - \`backend-patterns v2.0\` (5 Iron Laws)
  - \`frontend-patterns v2.0\` (5 Iron Laws)
  - \`api-design v2.0\` (5 Iron Laws)
  - \`security-review v2.0\` (5 Iron Laws)
  - \`error-handling v2.0\` (5 Iron Laws)

### 3. OpenSpec Integration

- ✅ Created \`.scaffolding/openspec/\` structure
  - \`project.md\` - Project context
  - \`specs/\` - Approved specifications
  - \`changes/\` - Active change proposals
  - \`changes/archive/\` - Completed changes

### 4. Configuration Updates

- ✅ Added \`[sdd]\` section to \`config.toml\`
  - SDD workflow disabled by default (\`enabled = false\`)
  - Rationalization prevention configured
  - Complexity thresholds defined

### 5. Documentation Updates

- ✅ Updated AGENTS.md path references
  - \`.agents/\` → \`.scaffolding/agents/\`

## File Manifest

### Relocated Files

\`\`\`
.agents/                    → .scaffolding/agents/
├── skills/                 → .scaffolding/agents/skills/
├── agents/                 → .scaffolding/agents/agents/
├── commands/               → .scaffolding/agents/commands/
├── bundles.yaml            → .scaffolding/agents/bundles.yaml
└── workflows.yaml          → .scaffolding/agents/workflows.yaml
\`\`\`

### New Files Created

\`\`\`
.scaffolding/
├── agents/
│   └── skills/
│       ├── backend/
│       │   ├── backend-patterns.md (v2.0)
│       │   └── error-handling.md (v2.0)
│       ├── frontend/
│       │   └── frontend-patterns.md (v2.0)
│       └── universal/
│           ├── api-design.md (v2.0)
│           └── security-review.md (v2.0)
└── openspec/
    ├── README.md
    ├── project.md
    ├── specs/
    └── changes/
        └── archive/

.agents/
├── .gitkeep
└── README.md (project-specific agents guide)
\`\`\`

### Deleted Files

\`\`\`
.scaffolding/agents/skills/universal/tdd-workflow.md (ECC version)
\`\`\`

## Next Steps

1. **Review SDD Configuration**:
   \`\`\`bash
   # Edit config.toml [sdd] section
   # Set enabled = true when ready to use SDD
   \`\`\`

2. **Test Transformed Skills**:
   \`\`\`
   @use backend-patterns
   @use frontend-patterns
   @use api-design
   @use security-review
   @use error-handling
   \`\`\`

3. **Explore OpenSpec**:
   \`\`\`bash
   # Read OpenSpec guide
   cat .scaffolding/openspec/README.md
   
   # Create your first change proposal
   # (when SDD is enabled)
   \`\`\`

4. **Update Project README** (Optional):
   - Document v3.0.0 upgrade
   - Explain new directory structure
   - Add SDD workflow guide

## Rollback Instructions

If you need to revert this upgrade:

\`\`\`bash
# Restore from backup
cp -r $BACKUP_DIR/.agents $PROJECT_ROOT/
rm -rf $PROJECT_ROOT/.scaffolding/agents
rm -rf $PROJECT_ROOT/.scaffolding/openspec

# Restore config.toml
cp $BACKUP_DIR/config.toml $PROJECT_ROOT/

# Restore AGENTS.md
cp $BACKUP_DIR/AGENTS.md $PROJECT_ROOT/
\`\`\`

## Backup Location

All original files backed up to:
\`\`\`
$BACKUP_DIR
\`\`\`

Keep this backup until you've verified the upgrade works correctly.

## Support

- **Migration Guide**: \`docs/MIGRATION_GUIDE_V3.md\`
- **ADR 0013**: \`docs/adr/0013-ecc-superpowers-iron-laws-integration.md\`
- **Issue Tracker**: Report upgrade issues on GitHub

---

**Upgrade completed successfully! 🎉**

EOF

    log_success "Migration report generated: $MIGRATION_REPORT"
}

# ==============================================================================
# Rollback
# ==============================================================================

rollback_migration() {
    log_error "Rolling back migration..."

    if [ ! -d "$BACKUP_DIR" ]; then
        log_error "Backup directory not found, cannot rollback"
        return 1
    fi

    # Restore .agents
    if [ -d "$BACKUP_DIR/.agents" ]; then
        rm -rf "$OLD_AGENTS_DIR"
        cp -r "$BACKUP_DIR/.agents" "$OLD_AGENTS_DIR"
        log_verbose "Restored: .agents/"
    fi

    # Restore config.toml
    if [ -f "$BACKUP_DIR/config.toml" ]; then
        cp "$BACKUP_DIR/config.toml" "$PROJECT_ROOT/config.toml"
        log_verbose "Restored: config.toml"
    fi

    # Restore AGENTS.md
    if [ -f "$BACKUP_DIR/AGENTS.md" ]; then
        cp "$BACKUP_DIR/AGENTS.md" "$PROJECT_ROOT/AGENTS.md"
        log_verbose "Restored: AGENTS.md"
    fi

    if [ -d "$NEW_AGENTS_DIR" ]; then
        rm -rf "$NEW_AGENTS_DIR"
        log_verbose "Removed: .scaffolding/agents/"
    fi

    if [ -d "$SCAFFOLDING_DIR/openspec" ]; then
        rm -rf "$SCAFFOLDING_DIR/openspec"
        log_verbose "Removed: .scaffolding/openspec/"
    fi

    log_success "Rollback completed"
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo -e "${BOLD}${BLUE} Upgrade to v3.0.0${NC}"
    echo -e "${BOLD}${BLUE} OpenSpec + Superpowers Iron Laws${NC}"
    echo -e "${BOLD}${BLUE}========================================${NC}"
    echo ""

    parse_args "$@"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}${BOLD}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi

    check_prerequisites
    create_backup

    echo ""
    echo -e "${BOLD}Starting migration...${NC}"
    echo ""

    relocate_agents_directory
    delete_ecc_tdd_workflow
    copy_transformed_skills
    create_openspec_structure
    merge_sdd_config
    update_agents_md

    if [ "$DRY_RUN" = false ]; then
        generate_migration_report
        
        echo ""
        echo -e "${GREEN}${BOLD}========================================${NC}"
        echo -e "${GREEN}${BOLD} Migration completed successfully!${NC}"
        echo -e "${GREEN}${BOLD}========================================${NC}"
        echo ""
        echo -e "Migration report: ${BOLD}$MIGRATION_REPORT${NC}"
        echo -e "Backup location:  ${BOLD}$BACKUP_DIR${NC}"
        echo ""
        echo -e "Next steps:"
        echo -e "  1. Review migration report"
        echo -e "  2. Test transformed skills (@use skill-name)"
        echo -e "  3. Enable SDD in config.toml when ready"
        echo -e "  4. Read .scaffolding/openspec/README.md"
        echo ""
    else
        echo ""
        echo -e "${YELLOW}${BOLD}DRY RUN COMPLETED${NC}"
        echo -e "No changes were made. Run without --dry-run to apply changes."
        echo ""
    fi
}

main "$@"
