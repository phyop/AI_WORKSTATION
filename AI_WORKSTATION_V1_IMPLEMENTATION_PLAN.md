# AI Workstation V1 Implementation Plan

## 1. V1 目標

建立一個安全、可遠端操作、可重建、可版本控制的 AI Workstation。

使用者可在外出時僅使用手機，透過 SSH 安全連線至放在家中的主要節點；即使裝置處於鎖定畫面，仍可使用：

- Shell
- Git
- Python
- Codex CLI
- 專案測試與建置命令
- GitHub

V1 以目前主要節點為實作對象，但 Repository 結構與文件需保留 Windows、macOS、Linux 的擴充能力。

---

## 2. V1 成功條件

V1 完成時，必須滿足：

- [ ] 手機可透過 SSH Key 登入。
- [ ] 不依賴一般帳號密碼進行 SSH 遠端登入。
- [ ] 裝置鎖定畫面時 SSH Session 仍可正常建立與執行。
- [ ] 裝置不會在預期使用期間自動進入無法遠端連線的睡眠狀態。
- [ ] Git、Python、Codex CLI 可在 SSH Session 中執行。
- [ ] GitHub Clone、Pull、Commit、Push 可正常完成。
- [ ] 1Password 作為人工登入金鑰的第一優先管理方式。
- [ ] Git Repository 不包含任何 Secret。
- [ ] 所有安裝、設定、驗收與故障排除步驟均有文件。
- [ ] 可依 Repository 文件在另一個節點重建基本環境。
- [ ] 已完成回復方案與風險檢查。

---

# 3. 建置階段總覽

```text
Phase 0 盤點與決策
Phase 1 建立 Repository
Phase 2 主機基礎設定
Phase 3 安裝與設定 SSH Server
Phase 4 建立 SSH Key 與 1Password 管理
Phase 5 手機 SSH Client
Phase 6 遠端網路連線方案
Phase 7 Git 與 GitHub
Phase 8 Python 開發環境
Phase 9 Codex CLI
Phase 10 鎖定畫面與長時間運作驗證
Phase 11 安全加固
Phase 12 Agent Pool 紀錄
Phase 13 備份與回復
Phase 14 文件與 GitHub 發布
Phase 15 最終驗收
```

---

# Phase 0 — 盤點與架構決策

## 0.1 確認目前主要節點

記錄：

- [ ] 作業系統與版本
- [ ] 裝置名稱
- [ ] CPU
- [ ] RAM
- [ ] GPU
- [ ] 磁碟空間
- [ ] 網路連線方式
- [ ] 是否可長時間插電
- [ ] 是否會自動睡眠
- [ ] 是否有固定區域網路 IP
- [ ] 是否可設定路由器

建議輸出：

```text
docs/setup/current-node-inventory.md
```

## 0.2 決定 V1 遠端連線邊界

需明確選擇：

- 僅家中區域網路使用。
- 透過 VPN Overlay 使用。
- 直接將 SSH Port 暴露到 Internet。

V1 建議優先順序：

1. VPN Overlay
2. 僅區域網路
3. 不建議直接公開 SSH Port

需將決策寫入 ADR。

## 0.3 建立威脅模型

至少列出：

- 手機遺失。
- SSH Key 外洩。
- 家中他人接觸筆電。
- 路由器設定錯誤。
- Git Secret 誤提交。
- 裝置休眠或斷網。
- 遠端誤刪檔案。
- Codex CLI 執行高風險命令。
- Git Push 到錯誤 Repository。
- 1Password 帳號無法存取。

建議輸出：

```text
docs/security/threat-model-v1.md
```

---

# Phase 1 — 建立 Git Repository

## 1.1 建立專案

建議名稱：

```text
ai-engineering-platform
```

或：

```text
ai-workstation
```

## 1.2 建立初始結構

```text
ai-engineering-platform/
├── README.md
├── ROADMAP.md
├── ARCHITECTURE.md
├── SECURITY.md
├── CHANGELOG.md
├── .gitignore
├── .env.example
│
├── bootstrap/
│   ├── windows/
│   ├── macos/
│   └── linux/
│
├── configs/
│   ├── ssh/
│   ├── git/
│   └── shell/
│
├── scripts/
├── tests/
│
└── docs/
    ├── setup/
    ├── operations/
    ├── troubleshooting/
    ├── security/
    └── decisions/
```

## 1.3 建立 Secret 防護

`.gitignore` 至少包含：

```gitignore
.env
.env.*
!.env.example

*.pem
*.key
*.p12
*.pfx

id_rsa
id_rsa.*
id_ed25519
id_ed25519.*

secrets/
credentials/
private/
```

## 1.4 建立第一批 ADR

- [ ] ADR-001 Platform Agnostic
- [ ] ADR-002 Vendor Neutral
- [ ] ADR-003 Agent Pool
- [ ] ADR-004 Git as Source of Truth
- [ ] ADR-005 Secrets Never in Git
- [ ] ADR-006 Human-in-the-loop
- [ ] ADR-007 VPN-first Remote Access
- [ ] ADR-008 Future Mac mini Control Node

## 驗收

- [ ] Repository 可正常 Clone。
- [ ] Repository 結構完成。
- [ ] `.gitignore` 已驗證。
- [ ] Secret 測試檔不會被 Git 追蹤。
- [ ] 初始 Commit 已建立。

---

# Phase 2 — 主機基礎設定

## 2.1 建立專用使用者策略

評估：

- 使用現有個人帳號。
- 建立專用非管理員帳號。
- 建立遠端管理專用帳號。

V1 建議：

- 遠端日常操作使用非管理員帳號。
- 需要系統管理權限時才使用提升權限。
- 避免直接允許最高權限帳號遠端登入。

## 2.2 設定裝置名稱

使用固定、易辨識名稱，例如：

```text
ai-node-laptop-01
```

## 2.3 設定電源

目標：

- 鎖定畫面時仍保持運作。
- 插電狀態下不自動睡眠。
- 螢幕可關閉。
- 避免闔上螢幕後自動睡眠，除非散熱或硬體安全不允許。

## 2.4 設定時間與時區

- [ ] 時區正確。
- [ ] 系統時間同步。
- [ ] Log 時間可追蹤。

## 2.5 確認磁碟與散熱

- [ ] 保留足夠磁碟空間。
- [ ] 長時間插電不阻礙散熱。
- [ ] 不將筆電放置在封閉、高溫或易燃區域。
- [ ] 評估電池保護或充電上限功能。

## 驗收

- [ ] 裝置鎖定 30 分鐘後仍可本地網路 Ping 或連線。
- [ ] 插電狀態不會自動睡眠。
- [ ] 非管理員帳號可正常登入與開發。
- [ ] 裝置名稱與時間設定完成。

---

# Phase 3 — 安裝與設定 SSH Server

## 3.1 安裝 SSH Server

依作業系統建立對應腳本與文件：

```text
bootstrap/windows/
bootstrap/macos/
bootstrap/linux/
```

只需實作目前主要節點，其餘保留 Placeholder。

## 3.2 啟用開機自動啟動

- [ ] SSH Server 在系統啟動時自動啟動。
- [ ] 服務失敗時可查看 Log。
- [ ] 服務重啟方式已文件化。

## 3.3 建立 SSH 設定範本

Git 中僅保存範本：

```text
configs/ssh/sshd_config.example
```

至少規劃：

- 禁止空密碼。
- 優先使用 Public Key。
- 限制可登入使用者。
- 不允許最高管理權限帳號直接登入。
- 設定合理的登入重試次數。
- 設定 Idle Session 策略。
- 保留必要 Log。

## 3.4 主機金鑰指紋

第一次連線時，記錄並驗證 Host Key Fingerprint。

建議輸出：

```text
docs/security/ssh-host-fingerprint.md
```

不得將 Private Host Key 放入 Git。

## 驗收

- [ ] SSH Server 正常啟動。
- [ ] 本機可透過 SSH 登入。
- [ ] 同一區域網路另一台裝置可登入。
- [ ] SSH Server 重開機後自動啟動。
- [ ] 錯誤密碼或錯誤金鑰會被拒絕。
- [ ] Log 可查詢。

---

# Phase 4 — SSH Key 與 1Password

## 4.1 建立 Key 管理原則

第一優先：

```text
1Password
```

第二優先：

```text
Google Password Manager
```

但 Google Password Manager 不應在未確認 SSH Key 支援模式前，被視為 SSH Private Key 的等價替代。

## 4.2 Key 分類

至少區分：

- 手機登入主要節點的 SSH Key。
- 個人 GitHub SSH Key。
- 未來服務帳號或 CI/CD Key。

不同用途避免共用同一把 Key。

## 4.3 建立 SSH Key

建議使用現代金鑰類型，例如 Ed25519。

建立時：

- [ ] 設定有意義的名稱。
- [ ] 設定 Passphrase。
- [ ] Private Key 匯入或管理於 1Password。
- [ ] Public Key 安裝至主機。
- [ ] 記錄用途與建立日期。
- [ ] 設定失效與撤銷流程。

## 4.4 建立 Key Inventory

Git 中只記錄 Metadata，不記錄 Secret：

```yaml
keys:
  - name: mobile-to-ai-node
    purpose: ssh-login
    owner: sean
    private_key_location: 1password
    public_key_installed_on:
      - ai-node-laptop-01
    created_at: YYYY-MM-DD
    rotation_policy: review-annually
```

## 4.5 撤銷流程

必須文件化：

- 手機遺失時如何移除 Public Key。
- 1Password 無法存取時如何恢復。
- Key 疑似外洩時如何重新建立。
- 如何確認舊 Key 已失效。

## 驗收

- [ ] 手機使用 SSH Key 登入成功。
- [ ] Private Key 不存在於 Git。
- [ ] Private Key 不以明文存放在一般資料夾。
- [ ] 移除 Public Key 後登入會失敗。
- [ ] 撤銷流程已測試至少一次。

---

# Phase 5 — 手機 SSH Client

## 5.1 選擇 Client

評估項目：

- 是否支援 SSH Key。
- 是否可與 1Password 整合。
- 是否支援 Host Key 驗證。
- 是否支援 Port Forwarding。
- 是否支援 SFTP。
- 是否支援多裝置同步。
- 是否會將 Secret 上傳至不明服務。
- 是否支援 Android 或 iOS。

## 5.2 建立連線設定

設定：

- Host Alias。
- Hostname 或 VPN IP。
- Username。
- Port。
- Private Key。
- Host Key Verification。
- Keepalive。

## 5.3 手機操作體驗

驗證：

- [ ] 登入。
- [ ] 執行基本命令。
- [ ] 使用 tmux 或等價工具保持 Session。
- [ ] 查看 Git Status。
- [ ] 執行 Python。
- [ ] 啟動 Codex CLI。
- [ ] 網路切換後重新連線。

## 驗收

- [ ] 行動網路可連線。
- [ ] Wi-Fi 可連線。
- [ ] Host Key 不一致時會警告。
- [ ] 手機鎖定再解鎖後可恢復工作。
- [ ] 長命令不會因短暫斷線而直接遺失全部進度。

---

# Phase 6 — 遠端網路方案

## 6.1 優先使用 VPN Overlay

V1 建議使用：

- Tailscale
- ZeroTier
- 其他具備 WireGuard 類型能力的可信方案

原則：

- 不直接在路由器公開 SSH Port。
- 不依賴固定公網 IP。
- 使用裝置身分與加密網路。
- 可撤銷特定裝置。

## 6.2 建立網路拓樸文件

```text
手機
  │
  ▼
VPN Overlay
  │
  ▼
AI Workstation
```

## 6.3 設定 ACL 或裝置限制

至少規劃：

- 只有自己的手機與管理裝置可連線。
- 不允許不必要的其他節點存取 SSH。
- 未來服務 Port 與 SSH Port 分開管理。

## 6.4 測試網路情境

- [ ] 家中 Wi-Fi。
- [ ] 手機 4G/5G。
- [ ] 公共 Wi-Fi。
- [ ] 家中路由器重啟。
- [ ] 主機重啟。
- [ ] VPN Client 重啟。
- [ ] IP 變更。

## 驗收

- [ ] 無需開放路由器 SSH Port。
- [ ] 行動網路可連入。
- [ ] 未授權裝置無法連入。
- [ ] 主機與手機重啟後可恢復。
- [ ] 連線方式已文件化。

---

# Phase 7 — Git 與 GitHub

## 7.1 安裝 Git

- [ ] Git 可於 SSH Session 執行。
- [ ] 設定使用者名稱與 Email。
- [ ] 設定換行策略。
- [ ] 設定預設分支名稱。
- [ ] 設定常用 Alias。

## 7.2 GitHub 驗證

建議分開考慮：

- SSH Key。
- GitHub CLI。
- Fine-grained Token。

優先採用可撤銷、最小權限與易稽核方式。

## 7.3 Repository 隔離

每一個獨立專案各自擁有 `.git`：

```text
projects/
├── project-a/.git
├── project-b/.git
└── project-c/.git
```

不要在父層建立一個 `.git` 混合所有無關專案。

## 7.4 Secret Scan

至少加入：

- `.gitignore`
- Pre-commit Secret Scan
- GitHub Secret Scanning（若方案支援）
- Commit 前人工檢查

## 7.5 Git 遠端操作驗證

- [ ] Clone。
- [ ] Branch。
- [ ] Commit。
- [ ] Pull。
- [ ] Push。
- [ ] 查看 Diff。
- [ ] 建立與刪除測試 Branch。
- [ ] 回復錯誤修改。

## 驗收

- [ ] 手機 SSH Session 可完成完整 Git 流程。
- [ ] GitHub 驗證不需每次輸入帳號密碼。
- [ ] Secret 測試字串可被檢查機制攔截。
- [ ] 專案 Repository 彼此隔離。
- [ ] 已建立 Git 操作 SOP。

---

# Phase 8 — Python 開發環境

## 8.1 選擇環境管理方式

可評估：

- uv
- venv + pip
- Conda
- pyenv

V1 建議選擇一個主要方案，避免同一節點混用過多環境管理器。

## 8.2 建立版本規範

- Python Version。
- Project-specific Virtual Environment。
- Lock File。
- Dependency Declaration。
- Dev Dependency。
- Test Command。

## 8.3 建立 Bootstrap Script

例如：

```text
bootstrap/<os>/install-python.*
scripts/create-python-project.*
```

## 8.4 建立測試專案

測試專案至少包含：

- `pyproject.toml`
- `src/`
- `tests/`
- README
- 一個 CLI
- 一個單元測試

## 驗收

- [ ] SSH Session 可建立 Virtual Environment。
- [ ] 可安裝 Dependency。
- [ ] 可執行 Python CLI。
- [ ] 可執行單元測試。
- [ ] 可重建相同環境。
- [ ] Python 快取與 Virtual Environment 不會提交到 Git。

---

# Phase 9 — Codex CLI

## 9.1 安裝前確認

- [ ] Node.js 或必要 Runtime 版本。
- [ ] Codex CLI 安裝來源。
- [ ] 登入與授權方式。
- [ ] API Key 或帳號驗證方式。
- [ ] SSH 非互動環境是否可用。
- [ ] 更新與移除方式。

## 9.2 安裝 Codex CLI

將安裝命令納入：

```text
bootstrap/<os>/install-codex.*
```

不要在腳本中寫入真實 Token。

## 9.3 驗證基本操作

- [ ] 顯示版本。
- [ ] 顯示 Help。
- [ ] 在測試 Repository 啟動。
- [ ] 讀取專案檔案。
- [ ] 建議修改。
- [ ] 執行測試。
- [ ] 產生 Git Diff。
- [ ] 不自動 Push 正式分支。

## 9.4 建立安全規則

Codex CLI 預設原則：

- 修改前先讀取 Repository 規範。
- 高風險命令需人工確認。
- 不直接存取未授權資料夾。
- 不讀取 Secret。
- 不自動 Push。
- 不自動 Merge。
- 不刪除大量檔案。
- 修改後必須執行測試或至少輸出驗證方式。

## 9.5 建立 Codex 使用文件

```text
agents/codex/
├── README.md
├── CAPABILITIES.md
├── LIMITATIONS.md
├── SECURITY.md
└── PROMPT_TEMPLATE.md
```

## 驗收

- [ ] 手機 SSH 中可啟動 Codex CLI。
- [ ] Codex 可操作測試 Repository。
- [ ] 斷線後可透過 tmux 或等價方案恢復。
- [ ] Codex 不會取得未授權 Secret。
- [ ] 修改結果可透過 Git Diff 審核。
- [ ] Push 前保留人工確認。

---

# Phase 10 — 鎖定畫面與長時間運作

## 10.1 鎖定測試

流程：

1. 主機正常登入。
2. 啟動 SSH Server。
3. 鎖定主機畫面。
4. 手機透過行動網路連線。
5. 執行 Shell、Git、Python、Codex。
6. 保持 30～60 分鐘。
7. 再次確認 Session 狀態。

## 10.2 重開機測試

- [ ] 主機重新開機。
- [ ] 不進行桌面互動。
- [ ] SSH Server 自動啟動。
- [ ] VPN Client 自動啟動。
- [ ] 手機可重新連線。

需注意：部分作業系統或加密機制可能要求首次本地解鎖後，某些服務才可完整運作。此限制需實測並文件化。

## 10.3 斷線恢復

使用：

- tmux
- screen
- systemd service
- launchd
- Task Scheduler
- 其他適合平台的機制

目標：

- SSH 斷線不會中止長時間工作。
- 可重新登入並恢復 Session。
- 長時間任務有 Log。

## 10.4 網路異常測試

- [ ] 手機切換 Wi-Fi / 行動網路。
- [ ] VPN 短暫斷線。
- [ ] 家中網路重新撥號。
- [ ] Router 重啟。
- [ ] SSH Session 中斷後重新連線。

## 驗收

- [ ] 鎖定畫面下功能正常。
- [ ] 斷線後工作可恢復。
- [ ] 重開機後核心服務自動恢復。
- [ ] 睡眠與休眠行為符合設計。
- [ ] 所有限制與例外已記錄。

---

# Phase 11 — 安全加固

## 11.1 SSH

- [ ] 停用密碼登入，確認 Key 登入完全正常後再執行。
- [ ] 限制登入使用者。
- [ ] 禁止最高權限帳號直接登入。
- [ ] 設定登入重試限制。
- [ ] 啟用必要 Log。
- [ ] 定期檢查 Authorized Keys。
- [ ] 不直接公開 Internet Port。

## 11.2 帳號

- [ ] 遠端日常帳號採最小權限。
- [ ] 管理權限僅在必要時提升。
- [ ] 主機本地帳號有強密碼。
- [ ] 手機有鎖定、生物辨識與遠端清除能力。
- [ ] 1Password 啟用多因素驗證。

## 11.3 Git

- [ ] 啟用 Secret Scan。
- [ ] `.env.example` 不含真實值。
- [ ] Commit 前檢查 Diff。
- [ ] 不允許 AI 自動 Push 正式分支。
- [ ] 重要分支啟用保護規則。

## 11.4 作業系統安全

BitLocker、FileVault、LUKS、防毒、防火牆等功能應在 V1 做「評估與記錄」，不必因缺乏經驗而一次全部啟用。

至少需記錄：

- 是否啟用磁碟加密。
- 是否啟用系統防火牆。
- 是否有自動安全更新。
- 若裝置遭竊，資料暴露風險。
- 啟用加密後對遠端重開機的影響。

## 11.5 高風險命令 Policy

至少列入人工批准：

```text
rm -rf
del /s
format
diskpart
sudo
Run as Administrator
git push --force
git reset --hard
git clean -fdx
修改防火牆
修改 SSH 設定
修改使用者權限
刪除 Repository
部署正式環境
```

## 驗收

- [ ] 密碼登入已停用或有明確保留理由。
- [ ] 未授權帳號無法登入。
- [ ] 公網無直接 SSH Port。
- [ ] 手機遺失與 Key 撤銷 SOP 完成。
- [ ] Secret Scan 可運作。
- [ ] 高風險操作有人工批准規則。

---

# Phase 12 — Agent Pool 使用紀錄

## 12.1 建立 Agent Profile

為每個工具建立：

- Capabilities
- Strengths
- Weaknesses
- Best Use Cases
- Failure Patterns
- Cost Model
- Privacy Notes
- Fallback Options

Agent：

- Codex
- Cursor
- Claude
- Gemini
- Local LLM

V1 只需實際完成 Codex 與 Cursor 的初始 Profile，其餘可保留 Placeholder。

## 12.2 建立 Task Log Schema

例如：

```yaml
task_id: TASK-0001
date: YYYY-MM-DD
project: sample-project
task_type: bug_fix
agent_used: codex
fallback_agent:
result: success
human_review: approved
tests:
  - pytest
notes:
```

## 12.3 建立人工路由紀錄

每次重要任務記錄：

- 為何先選 Codex 或 Cursor。
- 卡在哪裡。
- 是否切換 Agent。
- 哪個 Agent 最終完成。
- 成本、時間、品質。
- 未來可轉換成什麼規則。

## 驗收

- [ ] Agent Profile 已建立。
- [ ] Task Log Schema 已建立。
- [ ] 至少記錄三個實際任務。
- [ ] 至少有一筆 Agent 切換案例，若實際發生。
- [ ] 紀錄不包含敏感內容。

---

# Phase 13 — 備份與回復

## 13.1 備份範圍

需備份：

- Repository。
- 未提交的重要工作。
- SSH Public Key Metadata。
- 設定文件。
- Script。
- Agent Log。
- 1Password Emergency Kit 的安全保存方式。

不得將 Private Key 明文備份至一般雲端硬碟。

## 13.2 回復情境

至少測試或演練：

- 手機遺失。
- SSH Key 外洩。
- 主機重灌。
- Git Repository 誤刪。
- 1Password 無法登入。
- VPN 帳號失效。
- SSH 設定錯誤導致無法登入。
- 主機硬碟損壞。

## 13.3 Break-glass Access

建立緊急存取方案：

- 本地實體登入。
- 備援管理裝置。
- 備援 SSH Key。
- 1Password Recovery。
- 路由器本地管理。

緊急 Key 不應放在日常使用裝置上。

## 驗收

- [ ] Repository 可從遠端重新 Clone。
- [ ] 新 Key 可重新部署。
- [ ] 舊 Key 可撤銷。
- [ ] SSH 設定錯誤時有本地修復方案。
- [ ] 至少完成一次模擬回復。

---

# Phase 14 — 文件與 GitHub 發布

## 14.1 README

應包含：

- 專案目標。
- 使用情境。
- 核心架構。
- V1 功能。
- 安全原則。
- 快速開始。
- Repository 結構。
- Roadmap。
- 限制。
- 未來規劃。

## 14.2 Setup 文件

```text
docs/setup/
├── current-node-inventory.md
├── ssh-server-setup.md
├── mobile-client-setup.md
├── vpn-overlay-setup.md
├── git-github-setup.md
├── python-setup.md
└── codex-cli-setup.md
```

## 14.3 Operations 文件

```text
docs/operations/
├── daily-use.md
├── start-stop-services.md
├── rotate-ssh-key.md
├── add-new-device.md
├── remove-device.md
└── remote-development-sop.md
```

## 14.4 Troubleshooting 文件

```text
docs/troubleshooting/
├── ssh-cannot-connect.md
├── vpn-offline.md
├── codex-cli-login.md
├── git-authentication.md
├── host-key-changed.md
└── system-sleep.md
```

## 14.5 Security 文件

```text
docs/security/
├── threat-model-v1.md
├── secrets-management.md
├── key-inventory.example.yaml
├── incident-response.md
└── hardening-checklist.md
```

## 14.6 作品集輸出

V1 完成後產生：

- GitHub README。
- Medium 技術文章。
- Architecture Diagram。
- Demo Screenshot。
- Resume Bullet。
- LinkedIn 專案介紹。
- Release Notes。

## 驗收

- [ ] 新使用者可依文件理解架構。
- [ ] 未包含真實 IP、Key、Token、帳號或家庭網路敏感資訊。
- [ ] 所有命令均經實測。
- [ ] 文件與實際設定一致。
- [ ] GitHub Repository 結構清楚。

---

# Phase 15 — 最終驗收

## 15.1 功能測試

- [ ] 手機透過行動網路登入。
- [ ] 主機鎖定畫面下登入。
- [ ] 執行 Git。
- [ ] 執行 Python。
- [ ] 執行 Codex CLI。
- [ ] 啟動長時間工作。
- [ ] 中斷 SSH。
- [ ] 重新登入並恢復工作。
- [ ] Commit 與 Push 測試 Branch。
- [ ] 主機重啟後服務恢復。

## 15.2 安全測試

- [ ] 錯誤 Key 無法登入。
- [ ] 已撤銷 Key 無法登入。
- [ ] 未授權 VPN 裝置無法連線。
- [ ] Git 不追蹤 Secret。
- [ ] AI 無法讀取未授權 Secret。
- [ ] 高風險操作需人工批准。
- [ ] Host Key 變更會被發現。

## 15.3 回復測試

- [ ] 備援裝置可登入。
- [ ] 可新增新 Key。
- [ ] 可移除舊 Key。
- [ ] 可重建 Python 環境。
- [ ] 可重新安裝 Codex CLI。
- [ ] 可從 GitHub 重建主要設定。

## 15.4 文件測試

- [ ] README 完整。
- [ ] Setup 文件完整。
- [ ] Security 文件完整。
- [ ] Troubleshooting 文件完整。
- [ ] ADR 完整。
- [ ] 所有命令可複製執行。
- [ ] 所有平台差異有標示。

---

# 4. 建議實作順序

實際執行時，不要一次處理全部 Phase。

建議依序完成：

```text
Step 1 盤點目前主機與作業系統
Step 2 建立 Repository 與文件骨架
Step 3 選定 VPN Overlay
Step 4 安裝 SSH Server
Step 5 在區域網路測試 SSH
Step 6 建立與管理 SSH Key
Step 7 手機 SSH 測試
Step 8 行動網路與 VPN 測試
Step 9 調整鎖定、睡眠與重開機行為
Step 10 安裝 Git 與 GitHub 驗證
Step 11 安裝 Python 環境
Step 12 安裝 Codex CLI
Step 13 加入 tmux 或等價 Session 保持工具
Step 14 安全加固
Step 15 備份與回復演練
Step 16 完成文件、GitHub 與作品集輸出
```

---

# 5. 第一個實作起點

正式動工時，先完成：

```text
Phase 0.1 — 目前主要節點盤點
```

需要確認：

- 作業系統與版本。
- 筆電型號。
- 目前登入帳號類型。
- 是否有管理員權限。
- 網路路由器是否可管理。
- 是否已有 1Password。
- 手機系統是 Android 或 iOS。
- 是否已有 GitHub Account 與 SSH Key。
- 是否已安裝 Codex CLI。
- 筆電插電時目前的睡眠與闔蓋行為。

完成這一步後，再進入 Repository 建立與 SSH 架構選擇。
