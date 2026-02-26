# 任務完成清單 (Task Completion Checklist)

本文件追蹤 OpenCode 穩定性改善方案的實施進度。

---

## ✅ 已完成的任務

### 1. 系統配置與工具建立 ✅

- [x] 修復 `opencode.json` 語法錯誤
- [x] 配置 VSCode Extension Host 記憶體（8GB）
- [x] 建立 `.opencodeignore`
- [x] 建立自動化腳本（5 個）
- [x] 建立文件（3 個）
- [x] 安裝 git hooks
- [x] 建立驗證工具

**狀態**: ✅ 完成  
**完成時間**: 2026-02-26  
**驗證方式**: `./scripts/verify-setup.sh`

---

## ⏳ 待用戶完成的任務

### 2. 重啟 VSCode 使記憶體配置生效

**為什麼需要**: VSCode Extension Host 記憶體配置只有重啟後才會生效。

**如何完成**:
```bash
# 1. 儲存所有工作
# 2. 關閉所有 VSCode 視窗 (Cmd+Q)
# 3. 重新啟動 VSCode
```

**驗證方式**:
```bash
./scripts/verify-setup.sh
# 應該看到: ✓ VSCode memory configured: 8192MB
# 且沒有 "⚠ Cannot definitively confirm..." 警告
```

**狀態**: ⏳ 待用戶執行  
**預估時間**: 1 分鐘  
**阻塞原因**: 需要用戶手動重啟應用程式

**完成標準**:
- [ ] VSCode 已完全關閉
- [ ] VSCode 已重新啟動
- [ ] 驗證腳本顯示記憶體配置生效
- [ ] 沒有多實例警告

---

### 3. 測試單一 OpenCode 實例運行穩定性

**為什麼需要**: 確認修復是否有效，多實例是主要崩潰原因。

**如何完成**:
```bash
# 1. 檢查並關閉多餘實例
ps aux | grep -i "opencode --port" | grep -v grep

# 2. 只保留一個 OpenCode 實例
# 手動關閉其他 VSCode 視窗

# 3. 開始工作
./scripts/opencode-workflow.sh start

# 4. 正常工作 2-4 小時

# 5. 定期檢查
./scripts/opencode-workflow.sh health
```

**驗證方式**:
```bash
# 檢查運行實例
./scripts/verify-setup.sh

# 應該看到:
# ✓ One OpenCode instance running
```

**狀態**: ⏳ 待用戶執行  
**預估時間**: 1 天實際使用  
**阻塞原因**: 需要用戶實際工作並觀察

**完成標準**:
- [ ] 只運行一個 OpenCode 實例
- [ ] 連續工作 4+ 小時不崩潰
- [ ] Session 在重啟後完整保留
- [ ] 記憶體使用穩定在 < 6GB
- [ ] 沒有 ConfigInvalidError

**測試計劃**:
- **Day 1**: 測試基本功能（2-4 小時工作）
- **Day 2-3**: 測試複雜任務（long-running sessions）
- **Day 4-7**: 正常使用並記錄

---

### 4. 監控 7 天確認穩定性改善

**為什麼需要**: 量化改善效果，確認問題真正解決。

**如何完成**:
```bash
# 每天結束工作時執行（2 分鐘）
./scripts/monitor-stability.sh report

# 7 天後查看總結
./scripts/monitor-stability.sh summary
```

**監控指標**:
- 崩潰次數（目標：< 1 次/週）
- Session 恢復成功率（目標：100%）
- 最長連續工作時間（目標：> 4 小時）
- 最佳實踐遵守率（目標：> 80%）

**狀態**: ⏳ 待用戶執行  
**預估時間**: 7 天（每天 2 分鐘）  
**阻塞原因**: 需要時間經過

**完成標準**:
- [ ] 連續 7 天每日報告
- [ ] 崩潰次數 ≤ 1 次
- [ ] Session 恢復成功率 = 100%
- [ ] 平均工作時長 > 3 小時
- [ ] 總分 > 80/100

**每日報告問題**:
1. 是否崩潰？次數？
2. 最長連續工作時間？
3. 是否只開一個實例？
4. 是否頻繁 commit？
5. 記憶體是否 < 4GB？

---

## 📊 整體進度

| 任務 | 狀態 | 完成度 | 阻塞原因 |
|------|------|--------|----------|
| 系統配置與工具 | ✅ 完成 | 100% | - |
| 重啟 VSCode | ⏳ 待執行 | 0% | 需用戶手動操作 |
| 測試穩定性 | ⏳ 待執行 | 0% | 需用戶使用觀察 |
| 7 天監控 | ⏳ 待執行 | 0% | 需時間經過 |

**總體進度**: 1/4 任務完成 (25%)  
**可自動化進度**: 1/1 任務完成 (100%)  
**需用戶介入**: 3 個任務

---

## 🎯 下一步行動

### 立即執行（今天）

1. **重啟 VSCode** ⏰ 1 分鐘
   ```bash
   # 關閉所有 VSCode 視窗
   # 重新啟動
   ./scripts/verify-setup.sh  # 驗證
   ```

2. **關閉多餘實例** ⏰ 2 分鐘
   ```bash
   # 檢查
   ps aux | grep -i "opencode --port"
   
   # 只保留一個！
   ```

3. **開始使用新工作流程** ⏰ 5 分鐘
   ```bash
   ./scripts/opencode-workflow.sh start
   ```

### 每天執行

- 開始：`workflow start`
- 每小時：`workflow health`
- 結束：`monitor-stability.sh report`

### 7 天後

```bash
./scripts/monitor-stability.sh summary
```

---

## 📝 記錄模板

### 每日監控記錄

**日期**: ____________

- [ ] 崩潰次數: ____
- [ ] 最長工作時間: ____ 小時
- [ ] 只開一個實例: 是 / 否
- [ ] 頻繁 commit: 是 / 否
- [ ] 記憶體 < 4GB: 是 / 否
- [ ] 備註: ________________

---

## ✅ 任務完成確認

當以下**所有**條件滿足時，可以將任務標記為完成：

### 任務 2 - 重啟 VSCode
- [ ] `verify-setup.sh` 顯示記憶體配置生效
- [ ] 沒有"未重啟"警告
- [ ] OpenCode 可正常啟動

### 任務 3 - 測試穩定性
- [ ] 連續工作 4+ 小時不崩潰
- [ ] Session 可正常恢復
- [ ] `workflow health` 全綠

### 任務 4 - 7 天監控
- [ ] 完成 7 天每日報告
- [ ] `monitor-stability.sh summary` 顯示改善
- [ ] 崩潰次數 ≤ 1 次

---

## 🆘 如果遇到問題

### VSCode 重啟後記憶體仍然不足
```bash
# 檢查配置
cat ~/Library/Application\ Support/Code/User/argv.json

# 應該包含: "js-flags": "--max-old-space-size=8192"
# 如果沒有，重新執行:
./scripts/fix-opencode-stability.sh
```

### 仍然頻繁崩潰
```bash
# 檢查是否多實例
./scripts/verify-setup.sh

# 查看崩潰日誌
tail -100 ~/.local/share/opencode/log/*.log | grep -i error

# 恢復 session
./scripts/recover-opencode-sessions.sh
```

### 監控工具報錯
```bash
# 確保 Python 3 可用
python3 --version

# 檢查腳本權限
chmod +x scripts/*.sh
```

---

## 📚 相關文件

- [`GET_STARTED.md`](../GET_STARTED.md) - 快速開始指南
- [`docs/OPENCODE_STABILITY.md`](../docs/OPENCODE_STABILITY.md) - 完整穩定性文件
- [`docs/OPENCODE_WORKFLOW_CHECKLIST.md`](../docs/OPENCODE_WORKFLOW_CHECKLIST.md) - 工作流程清單

---

**最後更新**: 2026-02-26  
**版本**: 1.0
