#!/bin/bash
# Generate PR template based on user's language preference
# Version: 2.0.0
# Usage: ./generate-pr-template.sh [language]
#   language: zh-TW | en-US | zh-CN | ja-JP (optional, reads from config.toml if not provided)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_DIR="$PROJECT_ROOT/.scaffolding/templates/pr"
CONFIG_FILE="$PROJECT_ROOT/config.toml"
GITHUB_DIR="$PROJECT_ROOT/.github"
OUTPUT_FILE="$GITHUB_DIR/PULL_REQUEST_TEMPLATE.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to read language from config.toml
read_language_from_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        warn "config.toml not found. Falling back to en-US"
        echo "en-US"
        return
    fi

    # Read [locale] primary setting
    local lang=$(grep -A 5 '^\[locale\]' "$CONFIG_FILE" | grep '^primary' | sed 's/.*=\s*"\(.*\)".*/\1/' | tr -d ' ')
    
    if [ -z "$lang" ]; then
        warn "No [locale].primary found in config.toml. Falling back to en-US"
        echo "en-US"
        return
    fi

    echo "$lang"
}

# Function to validate language
validate_language() {
    local lang="$1"
    case "$lang" in
        zh-TW|en-US|zh-CN|ja-JP)
            return 0
            ;;
        *)
            error "Unsupported language: $lang"
            error "Supported languages: zh-TW, en-US, zh-CN, ja-JP"
            return 1
            ;;
    esac
}

# Function to check if PR templates are enabled
check_pr_template_enabled() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return 0  # Default to enabled if no config
    fi

    # Read [github] use_pr_template setting
    local enabled=$(grep -A 5 '^\[github\]' "$CONFIG_FILE" | grep '^use_pr_template' | sed 's/.*=\s*\(.*\)/\1/' | tr -d ' ')
    
    if [ "$enabled" = "false" ]; then
        return 1
    fi

    return 0
}

# Main logic
main() {
    info "PR Template Generator v2.0.0"
    echo ""

    # Check if PR templates are enabled
    if ! check_pr_template_enabled; then
        warn "PR templates are disabled in config.toml ([github].use_pr_template = false)"
        warn "Skipping PR template generation"
        exit 0
    fi

    # Determine language
    local LANGUAGE
    if [ -n "$1" ]; then
        LANGUAGE="$1"
        info "Using language from command line: $LANGUAGE"
    else
        LANGUAGE=$(read_language_from_config)
        info "Using language from config.toml: $LANGUAGE"
    fi

    # Validate language
    if ! validate_language "$LANGUAGE"; then
        exit 1
    fi

    # Check if template exists
    local TEMPLATE_FILE="$TEMPLATE_DIR/PULL_REQUEST_TEMPLATE.$LANGUAGE.md"
    if [ ! -f "$TEMPLATE_FILE" ]; then
        error "Template not found: $TEMPLATE_FILE"
        error "Available templates:"
        ls -1 "$TEMPLATE_DIR"/PULL_REQUEST_TEMPLATE.*.md 2>/dev/null || echo "  (none)"
        exit 1
    fi

    # Create .github directory if it doesn't exist
    if [ ! -d "$GITHUB_DIR" ]; then
        info "Creating .github directory"
        mkdir -p "$GITHUB_DIR"
    fi

    # Check if output file already exists
    if [ -f "$OUTPUT_FILE" ]; then
        warn "PR template already exists: $OUTPUT_FILE"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Keeping existing PR template"
            exit 0
        fi
    fi

    # Copy template
    info "Copying template: $TEMPLATE_FILE"
    cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

    # Verify
    if [ -f "$OUTPUT_FILE" ]; then
        info "PR template generated successfully!"
        info "Location: $OUTPUT_FILE"
        echo ""
        info "Language: $LANGUAGE"
        info "Template: PULL_REQUEST_TEMPLATE.$LANGUAGE.md"
        echo ""
        info "Next steps:"
        echo "  1. Review the generated template"
        echo "  2. Customize if needed"
        echo "  3. Commit to repository"
        echo "  4. Create a PR to test the template"
    else
        error "Failed to generate PR template"
        exit 1
    fi
}

# Run main function
main "$@"
