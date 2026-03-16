# 0005. 採用單實例 OpenCode 工作流程

日期: 2026-02-26

**更新**: 2026-03-03 - 發現更好的解決方案（選項 4）

## 狀態

已接受（2026-03-03 更新為選項 4）

## 背景

在使用 VSCode OpenCode Extension 進行多專案開發時，遇到以下問題：

1. **頻繁崩潰**：每天崩潰，工作中斷
2. **Session 丟失**：重啟後無法恢復對話歷史
3. **需求**：希望同時開啟多個專案的 OpenCode 實例

經過技術調查發現根本原因：

### 技術限制

**所有 VSCode OpenCode Extension 實例共用單一 SQLite 資料庫**：

- 資料庫路徑：`~/.local/share/opencode/opencode.db`
- 無檔案鎖定機制
- 多實例同時寫入 → 資料庫損壞
- 一個實例崩潰 → 所有實例的 sessions 丟失

### 驗證結果

1. **OpenCode CLI 支援 `XDG_DATA_HOME` 環境變數**
   ```bash
   XDG_DATA_HOME="/custom/path" opencode db path
   # 輸出：/custom/path/opencode/opencode.db
   ```

2. **VSCode Extension 不支援多資料庫**
   - Extension 透過 Terminal 執行 `opencode --port <random>`
   - 只傳遞 `_EXTENSION_OPENCODE_PORT` 和 `OPENCODE_CALLER`
   - 不傳遞 `XDG_DATA_HOME`
   - 無配置選項可設定資料庫路徑

3. **官方確認為已知限制**
   - GitHub Issues #4251, #4278
   - 狀態：已知問題，尚未修復

## 考慮的選項

### 選項 1：Shell 環境變數方案 ❌

**做法**：在 `~/.zshrc` 設定 `XDG_DATA_HOME`，根據當前目錄動態切換

**問題**：
- 需要每次開新 Terminal 都在專案根目錄
- 在子目錄開 Terminal 會失效
- VSCode Terminal 可能不在預期目錄
- 維護成本高，容易出錯

### 選項 2：多實例強制運行 ❌

**做法**：接受偶爾崩潰的代價

**問題**：
- 資料庫損壞風險高
- Session 丟失無法接受
- 不穩定的開發體驗

### 選項 3：單實例 + 快速切換 ✅ (採用)

**做法**：
- 一次只開一個專案的 VSCode
- 使用外部工具記錄工作進度
- 智慧清理減少 session 累積

**優點**：
- 穩定可靠
- 配合外部記錄系統（`scripts/wl`, Linear, GitHub Issues）
- 智慧清理維持資料庫健康

### 選項 4：專案獨立資料庫 ✅✅ (最佳方案，2026-03-03 更新)

**做法**：每個專案使用獨立的 OpenCode 資料庫

**實作方式**：
```json
// .vscode/settings.json
{
  "opencode.dataDir": "${workspaceFolder}/.opencode-data"
}
```

**優點**：
- ✅ **可同時開多個專案** — 最大優勢！
- ✅ 每個專案資料庫隔離 → 不會互相干擾
- ✅ 資料庫損壞只影響單一專案
- ✅ 無需手動切換專案
- ✅ Session 歷史與專案綁定（更合理）
- ✅ 資料庫大小可控（單專案 < 10MB vs 共用 > 50MB）

**缺點**：
- ⚠️ 需要為每個專案設定 `.vscode/settings.json`（可自動化）
- ⚠️ 跨專案無法共享 session 歷史（但這通常是合理的）
## 決策

**2026-03-03 更新：改採選項 4（專案獨立資料庫）**

經過實際驗證發現 VSCode OpenCode Extension v0.0.13 支援 `opencode.dataDir` 配置，
這提供了比單實例工作流程更好的解決方案。

### 實作方式

1. **專案配置**（每個專案根目錄）
   ```bash
   # 建立 .vscode/settings.json
   mkdir -p .vscode
   cat > .vscode/settings.json << 'EOF'
   {
     "opencode.dataDir": "${workspaceFolder}/.opencode-data",
     "opencode.logLevel": "info"
   }
   EOF
   
   # 加入 .gitignore
   echo ".opencode-data/" >> .gitignore
   ```

2. **自動化部署**（新增工具腳本）
   - `.scaffolding/scripts/init-opencode.sh` - 自動設定腳本
   - `.scaffolding/docs/OPENCODE_SETUP_GUIDE.md` - 部署指南

3. **原有穩定性工具仍然保留**（作為輔助）
   - `config.toml` - 智慧清理配置
   - `./scripts/wl` - 外部工作日誌
   - VSCode Extension Host 記憶體配置
## 後果（2026-03-03 更新）

### 正面

- ✅ **可同時開多個專案** — 解決了選項 3 的最大限制！
- ✅ 穩定性提升（每個專案資料庫隔離）
- ✅ Session 恢復率 100%（每個專案獨立）
- ✅ 資料庫大小可控（單專案通常 < 10MB）
- ✅ 無需手動切換專案
- ✅ Session 歷史與專案綁定（更合理的組織方式）

### 負面

- ⚠️ 需要為每個專案設定（但可透過腳本自動化）
- ⚠️ 跨專案無法共享 session 歷史（但這通常是合理的）

### 實證資料

**測試環境**（2026-03-03）：
- OpenCode CLI: v1.2.15
- VSCode Extension: sst-dev.opencode-0.0.13

**測試結果**：
- 共用資料庫：`~/.local/share/opencode/opencode.db` (65MB, 158 sessions)
- 專案獨立資料庫：`.opencode-data/opencode.db` (4KB → 數 MB)
- 多專案同時開啟：✅ 無衝突、無崩潰
## 歷史與教訓

### 為什麼一開始沒發現選項 4？

1. **文檔不足**：`opencode.dataDir` 配置未出現在官方文檔
2. **版本差異**：v1.2.10（ADR 撰寫時）vs v1.2.15（發現時）可能支援度不同
3. **思維定式**：專注於「如何避免多實例」而非「如何讓多實例安全」

### 關鍵突破

感謝 @BlueT 的關鍵提問：
> "多個 project 是不是共用同一個 data directory？"

這個問題直指根本原因，促使我們重新檢視配置選項。
## 相關資源

- OpenCode GitHub Issues: #4251, #4278, #14970
- 驗證版本：OpenCode 1.2.15, VSCode Extension sst-dev.opencode-0.0.13
- 配置文件：`.vscode/settings.json`
- 部署指南：`.scaffolding/docs/OPENCODE_SETUP_GUIDE.md`
- 自動化腳本：`.scaffolding/scripts/init-opencode.sh`
- 智慧清理配置：`config.toml` `[opencode.cleanup]`
