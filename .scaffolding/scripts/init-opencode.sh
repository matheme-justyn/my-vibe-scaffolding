#!/usr/bin/env bash
# OpenCode 專案獨立資料庫初始化腳本
# 解決多專案共用資料庫導致的衝突問題
#
# Usage: ./.scaffolding/scripts/init-opencode.sh
#
# 功能：
# 1. 建立 .vscode/settings.json（配置 opencode.dataDir）
# 2. 將 .opencode-data/ 加入 .gitignore
# 3. 顯示驗證指令

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 OpenCode 專案獨立資料庫初始化${NC}"
echo "================================"
echo ""

# 1. 檢查是否已經設定
if [ -f ".vscode/settings.json" ]; then
    if grep -q "opencode.dataDir" .vscode/settings.json 2>/dev/null; then
        echo -e "${YELLOW}⚠️  .vscode/settings.json 已包含 opencode.dataDir 配置${NC}"
        echo ""
        cat .vscode/settings.json
        echo ""
        read -p "是否覆蓋？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}✓ 保持現有配置${NC}"
            exit 0
        fi
    fi
fi

# 2. 建立 .vscode 目錄
echo "📁 建立 .vscode 目錄..."
mkdir -p .vscode

# 3. 建立 settings.json
echo "📝 建立 .vscode/settings.json..."

# 檢查是否有模板
if [ -f ".scaffolding/vscode/settings.json.template" ]; then
    cp .scaffolding/vscode/settings.json.template .vscode/settings.json
    echo -e "${GREEN}✓ 從模板複製${NC}"
else
    # 直接建立
    cat > .vscode/settings.json << 'EOF'
{
  "$schema": "https://code.visualstudio.com/schemas/vscode-settings",
  "// Description": "OpenCode 專案獨立資料庫配置 - 解決多專案衝突問題",
  
  "opencode.dataDir": "${workspaceFolder}/.opencode-data",
  "opencode.logLevel": "info"
}
EOF
    echo -e "${GREEN}✓ 直接建立${NC}"
fi

# 4. 更新 .gitignore
echo ""
echo "📝 更新 .gitignore..."

if ! grep -q "^\.opencode-data/$" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# OpenCode 專案獨立資料庫（本地資料，不應版控）" >> .gitignore
    echo ".opencode-data/" >> .gitignore
    echo -e "${GREEN}✓ 已加入 .opencode-data/${NC}"
else
    echo -e "${BLUE}✓ .gitignore 已包含 .opencode-data/${NC}"
fi

# 5. 顯示當前配置
echo ""
echo -e "${GREEN}✅ 配置完成！${NC}"
echo "====================="
echo ""
echo -e "${BLUE}當前配置：${NC}"
cat .vscode/settings.json
echo ""

# 6. 顯示下一步操作
echo -e "${YELLOW}⚠️  重要：必須重啟 VSCode 才會生效${NC}"
echo ""
echo -e "${BLUE}下一步操作：${NC}"
echo "  1. 關閉所有 VSCode 視窗"
echo "  2. 重新開啟此專案"
echo "  3. 驗證設定是否生效（見下方指令）"
echo ""

echo -e "${BLUE}驗證指令：${NC}"
echo "  # 重啟後，應該會看到新目錄被建立"
echo "  ls -la .opencode-data/"
echo ""
echo "  # 應該看到專案獨立的資料庫（初始很小）"
echo "  ls -lh .opencode-data/opencode.db"
echo ""

# 7. 顯示其他專案部署資訊
echo -e "${BLUE}💡 部署到其他專案：${NC}"
echo "  在其他專案的根目錄執行相同的腳本："
echo "  ${GREEN}./.scaffolding/scripts/init-opencode.sh${NC}"
echo ""
echo "  或手動複製："
echo "  ${GREEN}cp .scaffolding/vscode/settings.json.template <other-project>/.vscode/settings.json${NC}"
echo ""

# 8. 詳細文件連結
echo -e "${BLUE}📖 詳細文件：${NC}"
echo "  - ADR 0005: .scaffolding/docs/adr/0005-single-instance-opencode-workflow.md"
echo "  - 設定指南: .scaffolding/docs/OPENCODE_SETUP_GUIDE.md"
echo ""
