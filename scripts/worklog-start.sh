#!/usr/bin/env bash
# scripts/worklog-start.sh
# 開始一個新任務，記錄到本地日誌

set -euo pipefail

TASK_NAME="${1:-未命名任務}"
WORKLOG_DIR=".worklog"
CURRENT_MONTH=$(date '+%Y-%m')
WORKLOG_FILE="$WORKLOG_DIR/$CURRENT_MONTH.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# 確保 worklog 已初始化
if [ ! -d "$WORKLOG_DIR" ]; then
    ./scripts/worklog-init.sh
fi

# 記錄任務開始
cat >> "$WORKLOG_FILE" <<EOF

## [$TIMESTAMP] $TASK_NAME

**狀態**: 🔄 進行中

### 目標
- [ ] （待填寫具體子任務）

### 過程記錄
- $(date '+%H:%M') 開始任務

### 決策與問題
（記錄重要決策、遇到的問題、解決方案）

---

EOF

echo "✅ 任務已記錄: $TASK_NAME"
echo "📝 日誌位置: $WORKLOG_FILE"
echo ""
echo "💡 提示："
echo "   更新進度: ./scripts/worklog-update.sh \"完成了 X\""
echo "   完成任務: ./scripts/worklog-done.sh"
echo "   編輯日誌: vim $WORKLOG_FILE"
