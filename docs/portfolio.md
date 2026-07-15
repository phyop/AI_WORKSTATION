# Portfolio

## STAR-style resume bullets

- 將純規劃文件轉化為可執行的 Windows AI Workstation repository，建立 ADR、威脅模型、跨平台 bootstrap 結構與 Secret-ignore 驗收，讓環境設定具備可重建與可稽核性。
- 設計最小權限帳號流程，以 UAC、SecureString 與 well-known SID 驗證標準 Users／Administrators 邊界，避免 AI 開發工具取得持久管理員權限。
- 診斷 Windows OpenSSH Feature on Demand 長時間安裝問題，以 DISM／CBS、pending reboot、Windows Update source 與服務狀態建立唯讀證據鏈，最終辨識 servicing 延遲完成而避免不必要 Registry 修復。
- 建立 OpenSSH 分階段安全 rollout：服務自動啟動、本機協定驗證、Public Key 前關閉入站防火牆，將可用性驗收與外部暴露解耦。
- 協調 AI 與人工批准的 GitHub 工作流，處理分支分歧、PowerShell 5.1 編碼／語法問題、隱私掃描與 main 合併，維持 private repository 的乾淨歷史。

## LinkedIn project introduction

我把一台 Windows 筆電從兩份規劃文件逐步建成可稽核的 AI 工程工作站。專案以 private Git repository 管理架構、安全基線、ADR、bootstrap 腳本與驗收證據；採用非管理員開發帳號、UAC 人工批准及 Secret Never in Git 原則。OpenSSH 安裝曾長時間卡在 Windows servicing，我透過 DISM／CBS、pending reboot 與 FoD source 診斷，確認 capability 延遲完成，避免套用不必要的 Registry 修復。最終完成 sshd 自動啟動與本機協定驗證，並在 Public Key 就緒前維持入站防火牆關閉。下一步將加入 SSH Key、VPN Overlay、Python 與 Codex CLI。

## Conventional Commit

`docs: publish privacy-safe AI workstation case study`

## PR description

### Summary

Add privacy-safe GitHub portfolio collateral and a chronological Medium case study for the AI Workstation build.

### Changes

- Add a sanitized Medium article with neutral host, user, path, and network placeholders.
- Add STAR resume bullets, LinkedIn copy, publishing metadata, and follow-on project ideas.
- Document the human-in-the-loop security and troubleshooting outcomes without raw logs or credentials.

### Testing

- Repository verification script
- PowerShell syntax parsing
- Secret and privacy-pattern scan
- `git diff --check`

### Screenshots

Not applicable; no GUI product was introduced.

### Future Work

- Public-key-only SSH rollout
- VPN Overlay and scoped firewall policy
- Reproducible Python and Codex CLI bootstrap

## Follow-on projects

- AI Software Engineer：建立可重複的 Python CLI 測試專案、CI 與 dependency lockfile。
- AI Solution Architect：設計 VPN Overlay、ACL、裝置身分與多節點控制平面。
- AI Agent Consultant：建立 Agent 權限矩陣、審批政策、Secret broker 與稽核 dashboard。
