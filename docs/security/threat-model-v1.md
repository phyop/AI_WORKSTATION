# Threat Model V1

## 保護資產

原始碼、GitHub 存取權、SSH 身分、環境憑證、工作站控制權與稽核紀錄。

## 主要威脅與控制

| 威脅 | 控制 |
|---|---|
| SSH Key 遺失或外洩 | Passphrase、1Password、裝置鎖定、撤銷流程 |
| 公開 SSH 服務遭掃描 | VPN-first、不公開 Port、ACL |
| Git Secret 誤提交 | `.gitignore`、pre-commit/secret scan、人工 diff |
| Agent 越權讀取或推送 | 最小權限、目錄隔離、Push 人工確認 |
| 主機遺失或遭入侵 | 全碟加密、更新、非管理員日常帳號、Log |
| 供應商或 VPN 故障 | Vendor-neutral 文件、可替換元件、復原程序 |

## 信任邊界

手機、VPN Overlay、AI Workstation、GitHub 與 Secret Manager 是不同信任區；身分與權限不可在區域間隱式共用。
