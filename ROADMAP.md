# Roadmap

來源：`AI_WORKSTATION_V1_IMPLEMENTATION_PLAN.md`。

- [ ] Phase 0：盤點與架構決策
- [x] Phase 1：建立 Git Repository 基礎結構
- [ ] Phase 2：主機基礎設定（進行中：電源、時區、時間同步與非管理員帳號已完成；帳號首次登入及散熱條件待驗證；裝置名稱以 `<host>` 表示）
- [ ] Phase 3：SSH Server（進行中：Capability 已安裝，`sshd` 已為 Running／Automatic；入站防火牆保持停用，等待 Phase 4 Public Key、本機 Key 登入與重啟驗收）
- [ ] Phase 4：SSH Key 與 1Password
- [ ] Phase 5：手機 SSH Client
- [ ] Phase 6：VPN Overlay
- [ ] Phase 7：Git 與 GitHub
- [ ] Phase 8：Python 開發環境
- [ ] Phase 9：Codex CLI
- [ ] Phase 10：鎖定畫面與長時間運作
- [ ] Phase 11：安全加固

Phase 1 的完成狀態須以 `tests/verify-repository.ps1` 驗證結果為準。
