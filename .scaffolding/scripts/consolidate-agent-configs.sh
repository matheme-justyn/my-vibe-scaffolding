#!/bin/bash
# consolidate-agent-configs.sh
# 整併既有的 agent 配置（.claude, .roo 等）到統一的 .agents/ 目錄
# Template-level script: 幫助使用此鷹架的 repo 整併 agent 配置

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 顯示標題
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Agent Configs Consolidation Script                 ║"
echo "║   整併既有 Agent 配置到統一目錄                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 檢查是否在專案根目錄
if [ ! -f "config.toml" ]; then
    echo -e "${RED}錯誤：請在專案根目錄執行此腳本${NC}"
    exit 1
fi

# 讀取 config.toml 判斷模式
PROJECT_MODE=$(grep '^mode' config.toml 2>/dev/null | cut -d'=' -f2 | tr -d ' "' || echo "project")

if [ "$PROJECT_MODE" = "scaffolding" ]; then
    echo -e "${YELLOW}⚠️  偵測到 Scaffolding Mode${NC}"
    echo "此腳本是為使用此鷹架的專案設計，不應在鷹架開發模式下執行。"
    echo ""
    read -p "確定要繼續嗎？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 0
    fi
fi

# 建立 .agents 目錄
mkdir -p .agents/skills

echo -e "${BLUE}🔍 掃描既有的 agent 配置...${NC}"
echo ""

# 追蹤是否有找到配置
FOUND_CONFIGS=false

# 函數：整併 skills
consolidate_skills() {
    local source_dir=$1
    local tool_name=$2
    
    if [ -d "$source_dir" ]; then
        echo -e "${YELLOW}📦 發現 $tool_name skills: $source_dir${NC}"
        
        # 計算 skill 數量
        skill_count=$(find "$source_dir" -type f -name "SKILL.md" | wc -l | tr -d ' ')
        
        if [ "$skill_count" -gt 0 ]; then
            echo "   ➜ 找到 $skill_count 個 skills"
            
            # 列出所有 skills
            echo "   ➜ Skills 清單："
            find "$source_dir" -type f -name "SKILL.md" | while read -r skill_file; do
                skill_dir=$(dirname "$skill_file")
                skill_name=$(basename "$skill_dir")
                echo "      - $skill_name"
            done
            
            echo ""
            echo "   選項："
            echo "   1) 移動到 .agents/skills/ (推薦，跨工具共享)"
            echo "   2) 複製到 .agents/skills/ (保留原配置)"
            echo "   3) 跳過 (保持原樣)"
            echo ""
            read -p "   請選擇 (1/2/3): " -n 1 -r choice
            echo ""
            
            case $choice in
                1)
                    echo -e "   ${GREEN}✓ 移動 skills 到 .agents/skills/${NC}"
                    find "$source_dir" -maxdepth 1 -mindepth 1 -type d | while read -r skill_dir; do
                        skill_name=$(basename "$skill_dir")
                        if [ -f "$skill_dir/SKILL.md" ]; then
                            if [ -d ".agents/skills/$skill_name" ]; then
                                echo "      ⚠️  .agents/skills/$skill_name 已存在，跳過"
                            else
                                mv "$skill_dir" ".agents/skills/"
                                echo "      ✓ 移動 $skill_name"
                            fi
                        fi
                    done
                    
                    # 如果目錄空了，刪除
                    if [ -z "$(ls -A "$source_dir")" ]; then
                        rmdir "$source_dir"
                        echo "      ✓ 移除空目錄 $source_dir"
                    fi
                    ;;
                2)
                    echo -e "   ${GREEN}✓ 複製 skills 到 .agents/skills/${NC}"
                    find "$source_dir" -maxdepth 1 -mindepth 1 -type d | while read -r skill_dir; do
                        skill_name=$(basename "$skill_dir")
                        if [ -f "$skill_dir/SKILL.md" ]; then
                            if [ -d ".agents/skills/$skill_name" ]; then
                                echo "      ⚠️  .agents/skills/$skill_name 已存在，跳過"
                            else
                                cp -r "$skill_dir" ".agents/skills/"
                                echo "      ✓ 複製 $skill_name"
                            fi
                        fi
                    done
                    ;;
                3)
                    echo -e "   ${BLUE}➜ 跳過 $tool_name skills${NC}"
                    ;;
                *)
                    echo -e "   ${YELLOW}⚠️  無效選擇，跳過${NC}"
                    ;;
            esac
            
            FOUND_CONFIGS=true
        else
            echo "   ➜ 沒有找到 SKILL.md 檔案"
        fi
        
        echo ""
    fi
}

# 掃描 Claude Code 配置
consolidate_skills ".claude/skills" "Claude Code"

# 掃描 RooCode 配置
consolidate_skills ".roo/skills" "RooCode"

# 掃描 Cursor 配置
consolidate_skills ".cursor/skills" "Cursor"

# 處理其他可能的配置檔案
if [ -f ".claude/settings.json" ] || [ -f ".roo/settings.json" ]; then
    echo -e "${YELLOW}📝 發現工具特定設定檔${NC}"
    
    if [ -f ".claude/settings.json" ]; then
        echo "   - .claude/settings.json"
    fi
    if [ -f ".roo/settings.json" ]; then
        echo "   - .roo/settings.json"
    fi
    
    echo ""
    echo "   這些設定檔是工具特定的，建議保留。"
    echo "   如需移除，請手動刪除。"
    echo ""
fi

# 如果沒有找到任何配置
if [ "$FOUND_CONFIGS" = false ]; then
    echo -e "${GREEN}✓ 沒有發現需要整併的 agent 配置${NC}"
    echo ""
    echo "目前支援的配置目錄："
    echo "  - .claude/skills/ (Claude Code)"
    echo "  - .roo/skills/ (RooCode)"
    echo "  - .cursor/skills/ (Cursor)"
    echo ""
    echo "如果你使用其他 agent 工具，請手動將 skills 放入 .agents/skills/"
    exit 0
fi

# 顯示最終結果
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   整併完成！                                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 檢查 .agents/skills/ 中的 skills
final_count=$(find .agents/skills -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')

if [ "$final_count" -gt 0 ]; then
    echo -e "${BLUE}📦 .agents/skills/ 目前包含 $final_count 個 skills：${NC}"
    find .agents/skills -maxdepth 1 -mindepth 1 -type d | while read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        echo "   - $skill_name"
    done
    echo ""
fi

# 提醒更新 .gitignore
echo -e "${YELLOW}📝 別忘了更新 .gitignore：${NC}"
echo ""
echo "   # 工具特定的 agent 配置（已整併到 .agents/）"
echo "   .claude/"
echo "   .roo/"
echo "   .cursor/"
echo ""
echo "   # 跨工具共享配置（建議提交）"
echo "   # .agents/"
echo ""

# 提醒更新 AGENTS.md
echo -e "${YELLOW}📝 別忘了更新 AGENTS.md：${NC}"
echo ""
echo "   加入 Skill System 章節，說明如何使用 .agents/skills/"
echo "   參考：.scaffolding/docs/AGENTS_MD_GUIDE.md"
echo ""

# 提醒 commit
echo -e "${BLUE}🎉 建議提交變更：${NC}"
echo ""
echo "   git add .agents/ .gitignore AGENTS.md"
echo "   git commit -m \"refactor: consolidate agent configs to .agents/\""
echo ""

echo -e "${GREEN}✨ 完成！${NC}"
