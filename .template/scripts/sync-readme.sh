#!/bin/bash
# sync-readme.sh - Sync README.md from root to .template/ (scaffolding mode only)
#
# 用途：在鷹架模式下，同步根目錄 README.md 到 .template/README.md
# Purpose: Sync root README.md to .template/README.md in scaffolding mode
#
# Usage:
#   ./template/scripts/sync-readme.sh [--check-only]
#
# Options:
#   --check-only    只檢查是否同步，不執行同步（用於 pre-push hook）

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if both README files exist
if [ ! -f "README.md" ]; then
  echo -e "${RED}✗ 根目錄 README.md 不存在${NC}"
  exit 1
fi

if [ ! -f ".template/README.md" ]; then
  echo -e "${YELLOW}⚠ .template/README.md 不存在，將自動建立${NC}"
fi

# Compare files
if cmp -s README.md .template/README.md; then
  if [ "$CHECK_ONLY" = true ]; then
    exit 0  # Files are identical
  fi
  echo -e "${GREEN}✓ README.md 已同步${NC}"
  exit 0
else
  if [ "$CHECK_ONLY" = true ]; then
    echo -e "${RED}✗ README.md 與 .template/README.md 不同步${NC}"
    echo ""
    echo "請執行以下命令同步："
    echo "  ./.template/scripts/sync-readme.sh"
    echo ""
    echo "或臨時跳過（不建議）："
    echo "  git push --no-verify"
    exit 1
  fi
  
  echo -e "${YELLOW}正在同步 README.md → .template/README.md...${NC}"
  cp README.md .template/README.md
  echo -e "${GREEN}✓ 同步完成${NC}"
  echo ""
  echo "請記得 commit 變更："
  echo "  git add .template/README.md"
  echo "  git commit -m \"chore: sync README to .template/\""
fi
