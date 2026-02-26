# 🚀 立即行動指南 (Quick Start)

**你現在需要做的三件事：**

---

## 1️⃣ 重啟 VSCode（必須！）

```bash
# 1. 儲存所有工作
# 2. 關閉所有 VSCode 視窗
# 3. 重新啟動 VSCode
```

**為什麼？** VSCode Extension Host 記憶體已增加到 8GB，但需要重啟才會生效。

**驗證是否成功：**
```bash
cat ~/Library/Application\ Support/Code/User/argv.json
# 應該看到: "js-flags": "--max-old-space-size=8192"
```

---

## 2️⃣ 開始使用新的工作流程

### 每天開始工作時：

```bash
cd /path/to/project
./scripts/opencode-workflow.sh start
```

這會：
- ✅ 檢查是否有多個 OpenCode 實例
- ✅ 提示是否需要備份
- ✅ 顯示最佳實踐提醒

### 工作中（每小時）：

```bash
# 快速健康檢查
./scripts/opencode-workflow.sh health

# 或完整狀態
./scripts/opencode-workflow.sh status
```

### 提交工作時：

```bash
# 使用 workflow 輔助（推薦）
./scripts/opencode-workflow.sh commit

# 或使用一般 git（會自動顯示提醒）
git add -A
git commit -m "feat: your message"
```

**你會看到 git hook 自動提醒！** ✅

---

## 3️⃣ 建立每日監控習慣

### 每天結束工作時：

```bash
./scripts/monitor-stability.sh report
```

這會問你幾個簡單問題（2 分鐘）：
- 是否崩潰？
- 最長工作時間？
- 是否遵守最佳實踐？

### 7 天後查看成果：

```bash
./scripts/monitor-stability.sh summary
```

你會看到：
- 📊 崩潰頻率趨勢
- ⏱️ 平均工作時長
- ✅ 最佳實踐遵守率
- 🎯 自動化建議

---

## 📋 快速命令參考

| 命令 | 用途 | 頻率 |
|------|------|------|
| `workflow start` | 開始工作 | 每天 |
| `workflow health` | 快速檢查 | 每小時 |
| `workflow commit` | 智慧提交 | 每 30-60 分 |
| `backup-opencode-sessions.sh` | 手動備份 | 複雜工作前 |
| `monitor-stability.sh report` | 每日報告 | 每天結束時 |
| `monitor-stability.sh summary` | 7 天總結 | 7 天後 |

---

## 🎯 今天的目標

- [ ] 重啟 VSCode
- [ ] 關閉多餘的 OpenCode 實例（只保留一個）
- [ ] 執行 `workflow start`
- [ ] 工作 1 小時後執行 `workflow health`
- [ ] 每 30-60 分鐘 commit 一次
- [ ] 今晚執行 `monitor-stability.sh report`

---

## 💡 記住這三個原則

1. **一次一個** - 只開一個 OpenCode 實例
2. **經常 commit** - 30-60 分鐘一次
3. **每日監控** - 用 monitor-stability.sh 追蹤進度

---

## ❓ 疑難排解

### Q: "permission denied" 錯誤
```bash
chmod +x scripts/*.sh
```

### Q: workflow command not found
```bash
# 確保在專案根目錄
cd /Users/justyn.chen/Library/CloudStorage/Dropbox/6_digital/my-vibe-scaffolding
./scripts/opencode-workflow.sh health
```

### Q: Git hook 沒有執行
```bash
chmod +x .git/hooks/post-commit
```

---

## 📚 完整文件

- **穩定性指南**: `docs/OPENCODE_STABILITY.md`
- **工作流程清單**: `docs/OPENCODE_WORKFLOW_CHECKLIST.md`
- **腳本位置**: `scripts/`
  - `fix-opencode-stability.sh` - 初始設定（已執行）
  - `opencode-workflow.sh` - 日常工作流程
  - `backup-opencode-sessions.sh` - 備份工具
  - `recover-opencode-sessions.sh` - 恢復工具
  - `monitor-stability.sh` - 7 天監控

---

## 🎉 預期結果

**7 天後，你應該會看到：**

- ✅ 崩潰次數：每天 → < 每週一次
- ✅ Session 恢復率：失敗 → 100% 成功
- ✅ 連續工作時間：1-2 小時 → 4+ 小時
- ✅ 記憶體穩定：崩潰 → 穩定在 < 6GB

**現在：重啟 VSCode，開始新的穩定工作流程！** 🚀
