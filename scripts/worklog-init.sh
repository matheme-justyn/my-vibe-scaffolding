#!/usr/bin/env bash
# scripts/worklog-init.sh
# 初始化本地工作日誌系統（不依賴任何外部服務）

set -euo pipefail

WORKLOG_DIR=".worklog"
CURRENT_MONTH=$(date '+%Y-%m')
WORKLOG_FILE="$WORKLOG_DIR/$CURRENT_MONTH.md"

# 建立 worklog 目錄
if [ ! -d "$WORKLOG_DIR" ]; then
    mkdir -p "$WORKLOG_DIR"
    echo "✅ 建立工作日誌目錄: $WORKLOG_DIR"
fi

# 確保有 .gitignore（避免敏感資訊誤 commit）
if [ -f .gitignore ] && ! grep -q "^\.worklog/" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Work logs (optional: remove this line if you want to commit logs)" >> .gitignore
    echo ".worklog/" >> .gitignore
    echo "ℹ️  已將 .worklog/ 加入 .gitignore（可選擇性移除此規則來版控日誌）"
fi

# 建立本月日誌（如果不存在）
if [ ! -f "$WORKLOG_FILE" ]; then
    cat > "$WORKLOG_FILE" <<EOF
# Work Log - $(date '+%Y年%m月')

> 本地工作記錄，OpenCode 崩潰也不怕

---

EOF
    echo "✅ 建立本月日誌: $WORKLOG_FILE"
fi

echo ""
echo "🎯 工作日誌系統已就緒"
echo ""
echo "使用方式："
echo "  開始任務: ./scripts/worklog-start.sh \"任務名稱\""
echo "  更新進度: ./scripts/worklog-update.sh \"進度描述\""
echo "  完成任務: ./scripts/worklog-done.sh"
echo "  查看日誌: cat $WORKLOG_FILE"
