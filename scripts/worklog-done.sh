#!/usr/bin/env bash
# scripts/worklog-done.sh
# 標記當前任務完成

set -euo pipefail

WORKLOG_DIR=".worklog"
CURRENT_MONTH=$(date '+%Y-%m')
WORKLOG_FILE="$WORKLOG_DIR/$CURRENT_MONTH.md"
TIMESTAMP=$(date '+%H:%M')

if [ ! -f "$WORKLOG_FILE" ]; then
    echo "❌ 工作日誌不存在"
    exit 1
fi

# 找到最後一個「進行中」的任務，改成「完成」
# macOS 和 Linux sed 語法不同，這裡用 Perl 替代
perl -i -pe 's/\*\*狀態\*\*: 🔄 進行中/**狀態**: ✅ 已完成 ('"$TIMESTAMP"')/ if !$done && /進行中/ && ($done=1)' "$WORKLOG_FILE"

echo "✅ 任務已標記完成"
echo "📝 日誌位置: $WORKLOG_FILE"
echo ""
echo "💡 下一步："
echo "   開始新任務: ./scripts/worklog-start.sh \"新任務\""
echo "   查看日誌: cat $WORKLOG_FILE"
