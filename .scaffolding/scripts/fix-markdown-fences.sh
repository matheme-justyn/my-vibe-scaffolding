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
        sort -u || true)

if [[ -z "$FILES" ]]; then
    echo -e "${GREEN}✓ No markdown fences found. All clean!${NC}"
    exit 0
fi

echo -e "${YELLOW}Found markdown fences in the following files:${NC}"
echo "$FILES" | while read -r file; do
    [[ -n "$file" ]] && echo "  - ${file#$PROJECT_ROOT/}"
done
echo ""

# Backup
BACKUP_DIR="$PROJECT_ROOT/.markdown-fence-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}Creating backup in: ${BACKUP_DIR#$PROJECT_ROOT/}${NC}"

FIXED_COUNT=0

# Process each file
while IFS= read -r file; do
    [[ -z "$file" || ! -f "$file" ]] && continue
    
    # Backup
    BACKUP_FILE="$BACKUP_DIR/$(basename "$file")"
    cp "$file" "$BACKUP_FILE"
    
    # Create temp file with fences removed
    TEMP_FILE="${file}.tmp"
    
    # Process: Remove ```markdown opening and corresponding ``` closing
    awk '
    BEGIN { in_markdown_fence = 0 }
    
    # Opening fence
    /^```markdown$/ {
        in_markdown_fence = 1
        next
    }
    
    # Closing fence (only when we are in markdown fence)
    in_markdown_fence && /^```$/ {
        in_markdown_fence = 0
        next
    }
    
    # Print all other lines
    { print }
    ' "$file" > "$TEMP_FILE"
    
    # Check if anything changed
    if ! cmp -s "$file" "$TEMP_FILE"; then
        mv "$TEMP_FILE" "$file"
        echo -e "${GREEN}✓ Fixed: ${file#$PROJECT_ROOT/}${NC}"
        FIXED_COUNT=$((FIXED_COUNT + 1))
    else
        rm "$TEMP_FILE"
    fi
done <<< "$FILES"

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
