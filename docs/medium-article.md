# 我如何把一台 Windows 筆電，逐步變成安全的 AI 工程工作站

> 本文刻意移除使用者名稱、電腦名稱、本機路徑、IP、Email、SSH alias、主機指紋與原始診斷 Log。文中的 `<host>`、`<standard-user>`、`<project-root>` 均為中性代稱。

## 五個標題候選

1. 我如何把 Windows 筆電逐步變成安全的 AI 工程工作站
2. 從一份 Markdown 計畫，到可稽核的 OpenSSH AI 工作站
3. OpenSSH 安裝卡住十分鐘：一次 Windows DISM／CBS 實戰
4. AI 協作不是全自動：建立遠端工程工作站的安全閘門
5. 用 Git、ADR 與可重複腳本打造 Windows AI Workstation

## 起點：我需要的不是「裝幾個工具」

這個專案一開始只有兩份規劃文件。目標看似簡單：讓一台 Windows 筆電可從手機遠端進入，執行 Git、Python 與 Codex。但只要把「長時間在線」「遠端登入」「AI Agent 可操作檔案」放在一起，問題就不再只是安裝軟體，而是權限、憑證、網路邊界、復原能力與稽核責任。

因此第一個決定不是開 Port 22，而是先把所有工作納入受控 Git repository，以 Git 作為非敏感設定與文件的唯一真實來源。完成隱私清理與雙重驗證後，原始工程歷史保留在 private archive，另以乾淨歷史發布 public repository。公開版本包含 README、架構、安全基線、Roadmap、威脅模型、八份 ADR、平台分離的 bootstrap 目錄，以及可自動驗證 Secret 測試檔確實被忽略的 PowerShell 腳本。

## Phase 0：先盤點，再碰系統設定

我們先以唯讀方式取得作業系統、CPU、記憶體、GPU、磁碟、網路、電源與時間服務狀態。公開文章只保留工程結論：這是一台資源足以作為工作站的 Windows 11 筆電；插電與電池模式都已設定為不自動睡眠；時區正確，但 Windows Time 最初只使用本機 CMOS Clock。

時間同步是低風險、可驗證的 Phase 2 動作。Repository 新增一支需要 Administrator 的腳本，透過 UAC 設定 Windows Time，執行後確認來源、最後同步時間與無警告狀態。這也建立了後續慣例：系統變更必須有腳本、有人工批准、有執行後證據。

## 最小權限：新增標準使用者，而不是把 Agent 交給管理員

下一步是建立專用的非管理員帳號 `<standard-user>`，日後只用於 SSH、Git、Python、Codex 與一般開發。原管理員帳號保留作安裝、維護與復原入口。

這段過程暴露了兩個實務陷阱。第一，密碼不應經過聊天、Shell history 或 Log，因此建立腳本只在本機 UAC PowerShell 中以 SecureString 讀取。第二，Windows 本機帳號欄位與本地化群組名稱都有相容性限制：過長的 Description 會讓建立失敗，而 `Users`／`Administrators` 應以 well-known SID 解析實際本機名稱。修正後，驗收確認帳號已啟用、密碼為必要、屬於標準 Users，且不屬於 Administrators。

## OpenSSH：真正困難的是「安裝看似卡住」

OpenSSH Server 的安全 rollout 採兩道閘門：先安裝 capability 與服務，但在 Public Key 驗證前保持入站防火牆關閉；等 Phase 4 完成金鑰後，再停用密碼登入並開放受限網路來源。

第一次 `Add-WindowsCapability` 長時間停在 Running。外部監控只看到 DISM 與 Windows servicing 程序，卻沒有 `sshd` 服務。唯讀檢查發現 CBS 有 pending reboot，因此先停止重複嘗試並重新開機。重啟後安裝仍一度超時，於是我們沒有盲目重跑，而是建立 DISM／CBS 診斷腳本，收集 capability、pending signals、服務、Windows Update source 與必要 Log 摘要。

診斷中一度看到 Server 為 `NotPresent`，並考慮 Features on Demand 來源問題。為此建立了兩個工具：一個只讀取 FoD／Windows Update policy；另一個是帶 `-Approve` 與手動輸入 `YES` 的 Registry 修復腳本，而且明確不安裝 OpenSSH、不啟動服務、不改防火牆。

關鍵轉折是稍後再次診斷時，Server capability 已變成 `Installed`。也就是說，先前的 Windows servicing 並非永久失敗，而是延遲完成。此時正確動作不是套用假設中的 Registry 修復，而是取消它：設定 `sshd` 為 Automatic、啟動服務、關閉 OpenSSH 入站規則，並寫出稽核 JSON。

## 驗收：拒絕登入也是一種成功

最終本機驗證顯示：OpenSSH Server 已安裝、`sshd` 正在執行且會自動啟動、TCP 22 在本機回應、SSH protocol handshake 正常，而 BatchMode 登入回傳 `Permission denied`。在尚未放入 Public Key 的階段，這個拒絕正是預期安全結果；同時 Windows 防火牆阻擋外部入站，因此沒有提前暴露密碼登入面。

## AI 協作的真正價值

這不是「AI 全自動把電腦設定好」的故事。AI 負責拆解計畫、產生可重複腳本、掃描敏感資訊、比較 Git 分支、整理診斷假設與執行驗證；人類則批准 UAC、輸入只存在本機的密碼、決定是否重開機、確認是否合併到 main，以及阻止高風險捷徑。

最重要的工程經驗有四點：

1. 先建立安全邊界，再建立連線能力。
2. Windows servicing 很慢時，timeout 不等於失敗；先讀狀態與 Log。
3. 修復腳本也要有拒絕執行、人工確認與可逆說明。
4. Git 的價值不只在保存程式碼，更在保存決策、驗收與失敗路徑。

## 下一步

Phase 4 將建立專用 SSH Key，Private Key 只進入受控的 Secret Manager，Git 僅保存 public metadata。金鑰在本機成功驗證後，才會停用 password authentication、限制可登入使用者並啟用受限的防火牆規則。之後再加入 VPN Overlay、手機 SSH Client、GitHub 驗證、Python 環境與 Codex CLI。

一台可靠的 AI 工作站，不是因為它能遠端執行命令，而是因為每個能力都有邊界、每次變更都有證據、每條失敗路徑都有復原方式。

---

GitHub：https://github.com/phyop/AI_WORKSTATION

SEO title：Windows AI Workstation 實戰：用 Git、OpenSSH 與安全閘門建立遠端工程環境

Meta description：從隱私清理、最小權限帳號到 OpenSSH DISM/CBS 診斷，完整記錄如何以人工批准與可稽核腳本建立可公開重現的 Windows AI 工程工作站。

URL slug：windows-ai-workstation-openssh-security-gates

Tags：Windows、OpenSSH、DevOps、AI Engineering、Cybersecurity
