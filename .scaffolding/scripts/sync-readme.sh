#!/bin/bash
# sync-readme.sh - Sync all README.{locale}.md files from root to .scaffolding/ (scaffolding mode only)
#
# 用途：在鷹架模式下，自動同步根目錄所有 README*.md 到 .scaffolding/
# Purpose: Sync all README*.md files from root to .scaffolding/ in scaffolding mode
#
# 新增功能 (2026-03-10):
# - 自動偵測根目錄所有 README*.md 檔案
# - 同步所有語系檔案到 .scaffolding/
# - 支援多語系 README (README.md, README.zh-TW.md, README.ja-JP.md 等)
#
# Usage:
#   ./.scaffolding/scripts/sync-readme.sh [--check-only]
#
# Options:
#   --check-only    只檢查是否同步，不執行同步（用於 pre-push hook）

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
CHECK_ONLY=false
if [ "$1" = "--check-only" ]; then
  CHECK_ONLY=true
fi

# Check if config.toml exists
if [ ! -f "config.toml" ]; then
  echo -e "${RED}✗ config.toml 不存在${NC}"
  exit 1
fi

# Read mode from config.toml
MODE=$(grep "mode.*=.*\".*\"" config.toml | sed 's/.*"\(.*\)".*/\1/')

# Check if sync_readme is enabled
SYNC_README=$(grep "sync_readme.*=.*true" config.toml || echo "")

# Only operate in scaffolding mode with sync_readme enabled
if [ "$MODE" != "scaffolding" ]; then
  if [ "$CHECK_ONLY" = true ]; then
    exit 0  # Not in scaffolding mode, skip check
  fi
  echo -e "${YELLOW}⚠ 非鷹架模式 (mode != scaffolding)，不需同步 README${NC}"
  exit 0
fi

if [ -z "$SYNC_README" ]; then
  if [ "$CHECK_ONLY" = true ]; then
    exit 0  # sync_readme not enabled, skip check
  fi
  echo -e "${YELLOW}⚠ sync_readme 未啟用（config.toml 中設為 false 或未設定）${NC}"
  exit 0
fi

# Find all README*.md files in root directory
README_FILES=$(ls README*.md 2>/dev/null || echo "")

if [ -z "$README_FILES" ]; then
  echo -e "${RED}✗ 根目錄沒有任何 README*.md 檔案${NC}"
  exit 1
fi

echo -e "${BLUE}偵測到以下 README 檔案：${NC}"
echo "$README_FILES" | while read -r file; do
  echo "  - $file"
done
echo ""

# Check sync status for all files
ALL_SYNCED=true
FILES_TO_SYNC=""

for file in $README_FILES; do
  target=".scaffolding/$file"
  
  if [ ! -f "$target" ]; then
    ALL_SYNCED=false
    FILES_TO_SYNC="$FILES_TO_SYNC $file"
    if [ "$CHECK_ONLY" = false ]; then
      echo -e "${YELLOW}⚠ $target 不存在，將自動建立${NC}"
    fi
  elif ! cmp -s "$file" "$target"; then
    ALL_SYNCED=false
    FILES_TO_SYNC="$FILES_TO_SYNC $file"
  fi
done

# Check-only mode: report status and exit
if [ "$CHECK_ONLY" = true ]; then
  if [ "$ALL_SYNCED" = true ]; then
    echo -e "${GREEN}✓ 所有 README 檔案已同步${NC}"
    exit 0
  else
    echo -e "${RED}✗ 以下 README 檔案未同步：${NC}"
    for file in $FILES_TO_SYNC; do
      echo "  - $file"
    done
    echo ""
    echo -e "${YELLOW}請執行以下命令同步：${NC}"
    echo "  ./.scaffolding/scripts/sync-readme.sh"
    echo ""
    echo -e "${YELLOW}或臨時跳過（不建議）：${NC}"
    echo "  git push --no-verify"
    exit 1
  fi
fi

# Sync mode: copy all files
if [ "$ALL_SYNCED" = true ]; then
  echo -e "${GREEN}✓ 所有 README 檔案已同步${NC}"
  exit 0
fi

echo -e "${YELLOW}正在同步 README 檔案到 .scaffolding/...${NC}"
echo ""

SYNCED_COUNT=0
for file in $FILES_TO_SYNC; do
  target=".scaffolding/$file"
  echo -e "  ${BLUE}→${NC} $file ${BLUE}→${NC} $target"
  cp "$file" "$target"
  SYNCED_COUNT=$((SYNCED_COUNT + 1))
done

echo ""
echo -e "${GREEN}✓ 成功同步 $SYNCED_COUNT 個檔案${NC}"
echo ""
echo -e "${YELLOW}請記得 commit 變更：${NC}"
echo "  git add .scaffolding/README*.md"
echo "  git commit -m \"chore: sync README files to .scaffolding/\""
