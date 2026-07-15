# Security

## 基線

- 不提交 Private Key、Token、密碼、真實 `.env` 或正式環境憑證。
- 遠端連線使用 VPN Overlay 與 SSH Public Key；不依賴一般帳號密碼。
- 不在路由器公開 SSH Port。
- 最小權限、裝置限制、可撤銷金鑰與可追蹤 Log。
- Codex 與其他 Agent 不得讀取未明確授權的 Secret；Push 前由人員審核 diff。

## 誤提交處理

立即撤銷或輪替憑證；不要只刪除最新檔案。停止推送、保存必要稽核資訊，清理 Git 歷史後再驗證遠端 repository 與 clone。

## 回報

此 private repository 的安全問題請透過 repository owner 的私人管道回報，不要建立含敏感內容的公開 Issue。
