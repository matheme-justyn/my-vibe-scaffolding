#!/usr/bin/env bash
# scripts/worklog-update.sh
# 更新當前任務的進度

set -euo pipefail

UPDATE_TEXT="${1:-進度更新}"
WORKLOG_DIR=".worklog"
CURRENT_MONTH=$(date '+%Y-%m')
WORKLOG_FILE="$WORKLOG_DIR/$CURRENT_MONTH.md"
TIMESTAMP=$(date '+%H:%M')

if [ ! -f "$WORKLOG_FILE" ]; then
    echo "❌ 工作日誌不存在，請先執行: ./scripts/worklog-start.sh \"任務名稱\""
    exit 1
fi

# 在最後一個「過程記錄」區塊下新增一行
# 簡化實作：直接 append（實際應該找到最後一個任務區塊）
cat >> "$WORKLOG_FILE" <<EOF
- $TIMESTAMP $UPDATE_TEXT
EOF

echo "✅ 進度已更新: $UPDATE_TEXT"
echo "📝 日誌位置: $WORKLOG_FILE"
