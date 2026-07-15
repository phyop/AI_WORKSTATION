# OpenSSH Capability 卡住 — DISM / CBS 診斷（已解除）

> 2026-07-12 23:57 更新：延遲完成的 Windows servicing 已將 `OpenSSH.Server` 安裝成功。`sshd` 現為 Running／Automatic；入站防火牆保持停用。以下內容保留作為歷史診斷紀錄。`RepairContentServerSource=2` 修復未執行，現在也不需要執行。

## 目前狀態（2026-07-12，重開機後）

| 項目 | 狀態 |
|------|------|
| OpenSSH Server Capability | **NotPresent**（Client 已是 Installed） |
| `sshd` 服務 | 未建立 |
| Port 22 | 未開放 |
| 防火牆 | 未變更（系統未因此暴露 SSH） |
| CBS pending | **已清除**（`any_pending=false`；重開機時有跑 Windows Update） |
| 剩餘阻礙 | `RepairContentServerSource` 未設定；CBS 曾指向 FoD/`0x800f0954` |
| 建議 | 先同意並執行 `set-fod-repair-source-windows-update.ps1 -Approve`；**在此之前不要安裝** |

### 進度

1. ~~CBS pending~~：重開機並完成 Windows Update 後已清除。
2. **進行中**：處理 FoD 來源（`0x800f0954`），讓 `OpenSSH.Server` 能下載安裝。

## 為何會卡在 Server NotPresent

OpenSSH Server 是 Features on Demand 套件。`0x800f0954` 代表系統無法從目前的更新／修復來源取得該套件。Client 已安裝不代表 Server 套件可取得。

## 唯讀診斷腳本

路徑（請用你的實際 clone）：

```powershell
cd <project-root>
git fetch origin
git checkout cursor/openssh-diagnose-ps-path-2480
cd .\bootstrap\windows
Set-ExecutionPolicy -Scope Process Bypass -Force
```

### 1) DISM／CBS（已跑過；pending 已清）

```powershell
.\diagnose-openssh-dism-cbs.ps1
```

產出：

- `C:\ProgramData\AIWorkstation\openssh-dism-cbs-diagnose.json`
- `C:\ProgramData\AIWorkstation\openssh-dism-cbs-excerpts.txt`

### 2) FoD／Windows Update 來源（下一步請跑）

```powershell
.\diagnose-openssh-fod-source.ps1
```

產出：

- `C:\ProgramData\AIWorkstation\openssh-fod-source-diagnose.json`

兩支腳本都**不會**改登錄、不會安裝 OpenSSH、不會改防火牆。

> 腳本使用 **UTF-8 BOM + ASCII**，避免 Windows PowerShell 5.1 在繁中碼頁解析失敗。若仍看到 `ExpandProperty state` 錯誤，代表本機還沒拉到最新分支。

## 修復順序

### A. CBS pending — 完成

重開機時出現「Windows 更新中」，之後 `any_pending=false`。

### B. FoD `0x800f0954` — 範例主機現況

唯讀結果：

| 檢查 | 結果 |
|------|------|
| WSUS policy（`WindowsUpdate` / `AU`） | **不存在**（不是典型 WSUS 導向） |
| `DoNotConnectToInternetWindowsUpdateLocations` | 未設定 |
| `wuauserv` / `BITS` / `DoSvc` | Running + Automatic |
| `Servicing` | 存在，目前只有 `CountryCode=TW` |
| `RepairContentServerSource` | **未設定** |

結論：沒有 WSUS 原則擋住；但 FoD 修復來源未明確指定走 Windows Update。對 `0x800f0954` 的標準下一步是設 `RepairContentServerSource=2`（需人工同意）。

#### 需你同意後才執行（會改 HKLM）

```powershell
cd <project-root>
git pull origin cursor/openssh-diagnose-ps-path-2480
cd .\bootstrap\windows
.\set-fod-repair-source-windows-update.ps1 -Approve
```

腳本會要求再輸入 `YES`。它**只**寫入：

`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing\RepairContentServerSource = 2`

不會安裝 OpenSSH、不會開防火牆。

成功後：

1. 再跑一次 `.\diagnose-openssh-dism-cbs.ps1`，確認 `any_pending` 仍為 `false`
2. 才考慮**單次**安裝：`.\install-openssh-server.ps1`
   或設定 → 應用程式 → 選擇性功能 → OpenSSH 伺服器

撤銷此原則值：

```powershell
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing' -Name RepairContentServerSource
```

### C. 仍失敗才考慮

- `sfc /scannow` 與 `DISM /Online /Cleanup-Image /RestoreHealth`
- 不要在來源未修前反覆 `Add-WindowsCapability`

## 明確禁止（目前）

- 不要再次執行 `install-openssh-server.ps1`
- 不要手動重複 `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`
- 不要開啟 `OpenSSH-Server-In-TCP` 防火牆規則

## 相關檔案

- `bootstrap/windows/diagnose-openssh-dism-cbs.ps1`
- `bootstrap/windows/diagnose-openssh-fod-source.ps1`
- `bootstrap/windows/set-fod-repair-source-windows-update.ps1`（需 `-Approve`）
- `bootstrap/windows/install-openssh-server.ps1`（暫緩）
- `docs/setup/phase-3-openssh.md`
