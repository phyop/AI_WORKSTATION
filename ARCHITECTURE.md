# Architecture

## V1 邊界

手機 SSH Client → VPN Overlay → AI Workstation SSH Server → 隔離的 Git repositories。

禁止從 Internet 直接開放 SSH Port。主機設定由 repository 中的範本與 bootstrap 腳本重建；實際金鑰、Token、密碼與環境憑證由 1Password 或等價的受控祕密管理工具保存。

## 目錄責任

- `bootstrap/`：各平台可重複執行的安裝入口
- `configs/`：不含 Secret 的設定範本
- `scripts/`：日常操作與驗證工具
- `tests/`：自動化驗收
- `docs/`：建置、操作、故障排除、安全及 ADR
