#!/bin/bash
# 初始化從模板建立的新專案

set -e

echo "🎯 初始化新專案"
echo "=============="
echo ""

# 檢查是否在專案根目錄
if [ ! -f "VERSION" ]; then
    echo "❌ 錯誤：請在專案根目錄執行此腳本"
    exit 1
fi

# 讀取模板版本
TEMPLATE_VERSION=$(cat VERSION)

# 收集專案資訊
read -p "專案名稱: " PROJECT_NAME
read -p "專案描述（簡短）: " PROJECT_DESC
read -p "GitHub repo (username/repo-name): " GITHUB_REPO
read -p "主要語言 (typescript/python/go/rust): " MAIN_LANG

echo ""
echo "📝 專案資訊："
echo "   名稱: $PROJECT_NAME"
echo "   描述: $PROJECT_DESC"
echo "   Repo: $GITHUB_REPO"
echo "   語言: $MAIN_LANG"
echo "   模板版本: $TEMPLATE_VERSION"
echo ""

read -p "確認要初始化嗎？ (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 1. 記錄模板版本
echo "$TEMPLATE_VERSION" > .template-version
echo "✅ 已建立 .template-version"

# 2. 備份原始 README
if [ -f "README.md" ]; then
    mv README.md docs/TEMPLATE_README.md.backup
    echo "✅ 已備份模板 README → docs/TEMPLATE_README.md.backup"
fi

# 3. 建立新的 README
cat > README.md << EOF
# $PROJECT_NAME

> $PROJECT_DESC

[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)

---

## 功能特色

- （待補充）

## 技術棧

- **語言**: ${MAIN_LANG}
- **框架**: （待補充）

## 快速開始

### 環境需求

- （待補充）

### 安裝

\`\`\`bash
git clone https://github.com/${GITHUB_REPO}.git
cd $(basename $GITHUB_REPO)

# 安裝依賴
（待補充）
\`\`\`

### 設定

\`\`\`bash
cp .env.example .env
# 編輯 .env
\`\`\`

### 執行

\`\`\`bash
# 開發模式
（待補充）

# 測試
（待補充）
\`\`\`

## 專案結構

\`\`\`
（待補充）
\`\`\`

## 開發指南

參考 [AGENTS.md](./AGENTS.md) 中的編碼規範。

## 貢獻

參考 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 授權

MIT License - 詳見 [LICENSE](./LICENSE)

---

**基於**: [my-vibe-scaffolding](https://github.com/matheme-justyn/my-vibe-scaffolding) v${TEMPLATE_VERSION}

更多關於 README 撰寫的指引，請參考 [docs/README_GUIDE.md](./docs/README_GUIDE.md)
EOF

echo "✅ 已建立新的 README.md"

# 4. 更新 VERSION（專案從 0.1.0 開始）
echo "0.1.0" > VERSION
echo "✅ 已設定專案版本為 0.1.0"

# 5. 清理範例 ADR（可選）
read -p "要刪除範例 ADR 嗎？(建議保留 0001) (y/N): " del_adr
if [[ $del_adr =~ ^[Yy]$ ]]; then
    rm -f docs/adr/0002-example-*.md docs/adr/0003-example-*.md docs/adr/0004-example-*.md
    echo "✅ 已刪除範例 ADR（保留 0001）"
fi

# 6. 提示下一步
echo ""
echo "🎉 初始化完成！"
echo ""
echo "📋 下一步："
echo "   1. 編輯 README.md 補充專案資訊"
echo "   2. 更新 AGENTS.md 中的編碼規範"
echo "   3. 複製 .env.example → .env 並設定"
echo "   4. 刪除或調整不需要的檔案"
echo "   5. 初始化專案程式碼"
echo "   6. git commit -m \"chore: initialize project from template v${TEMPLATE_VERSION}\""
echo ""
echo "📚 參考文件："
echo "   - docs/README_GUIDE.md - README 撰寫指引"
echo "   - docs/DOCUMENTATION_GUIDELINES.md - 文件組織規範"
echo "   - TEMPLATE_SYNC.md - 模板同步指南"
echo ""
