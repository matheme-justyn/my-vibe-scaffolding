#!/usr/bin/env bash
# fix-markdown-fences.sh - Remove unnecessary ```markdown code fences from .md files
# See: ADR 0008 - No Markdown Code Fence in Markdown Files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Fixing markdown code fences in .md files...${NC}"
echo ""

# Find all .md files with ```markdown (excluding ADR 0008 and .git)
FILES=$(grep -rl '```markdown' --include="*.md" "$PROJECT_ROOT" 2>/dev/null | \
        grep -v '.git/' | \
        grep -v '0008-no-markdown-code-fence' | \
        sort -u)

if [[ -z "$FILES" ]]; then
    echo -e "${GREEN}✓ No markdown fences found. All clean!${NC}"
    exit 0
fi

echo -e "${YELLOW}Found markdown fences in the following files:${NC}"
echo "$FILES" | while read -r file; do
    echo "  - ${file#$PROJECT_ROOT/}"
done
echo ""

# Backup
BACKUP_DIR="$PROJECT_ROOT/.markdown-fence-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}Creating backup in: ${BACKUP_DIR#$PROJECT_ROOT/}${NC}"

FIXED_COUNT=0

# Process each file
echo "$FILES" | while read -r file; do
    if [[ ! -f "$file" ]]; then
        continue
    fi
    
    # Backup
    BACKUP_FILE="$BACKUP_DIR/$(basename "$file")"
    cp "$file" "$BACKUP_FILE"
    
    # Count occurrences before
    BEFORE=$(grep -c '```markdown' "$file" 2>/dev/null || echo 0)
    
    if [[ "$BEFORE" -eq 0 ]]; then
        continue
    fi
    
    # Fix: Remove lines with exactly ```markdown (opening fence)
    # Keep lines that mention ```markdown in prose (e.g., "use ```markdown")
    # This is a smart removal that preserves context while removing fence lines
    
    # Create temp file
    TEMP_FILE="${file}.tmp"
    
    # Process line by line
    awk '
    BEGIN { in_markdown_fence = 0; prev_blank = 0 }
    
    # Detect opening ```markdown fence
    /^```markdown$/ {
        in_markdown_fence = 1
        next  # Skip this line
    }
    
    # Detect closing ``` when inside markdown fence
    in_markdown_fence && /^```$/ {
        in_markdown_fence = 0
        next  # Skip this line
    }
    
    # Print all other lines
    !in_markdown_fence || !/^```markdown$/ {
        print
    }
    ' "$file" > "$TEMP_FILE"
    
    # Replace original file
    mv "$TEMP_FILE" "$file"
    
    # Count after
    AFTER=$(grep -c '```markdown' "$file" 2>/dev/null || echo 0)
    
    REMOVED=$((BEFORE - AFTER))
    
    if [[ "$REMOVED" -gt 0 ]]; then
        echo -e "${GREEN}✓ Fixed: ${file#$PROJECT_ROOT/} (removed $REMOVED fences)${NC}"
        ((FIXED_COUNT++)) || true
    fi
done

echo ""
echo -e "${GREEN}✓ Fixed $FIXED_COUNT files${NC}"
echo -e "${BLUE}Backup saved in: ${BACKUP_DIR#$PROJECT_ROOT/}${NC}"
echo ""
echo -e "${YELLOW}Please review changes with:${NC}"
echo "  git diff"
echo ""
echo -e "${YELLOW}If satisfied, commit with:${NC}"
echo "  git add -u"
echo "  git commit -m 'docs: remove unnecessary markdown code fences (ADR 0008)'"
