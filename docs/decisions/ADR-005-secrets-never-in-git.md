# ADR-005: Secrets Never in Git

Status: Accepted

Private Key、Token、密碼、正式憑證與真實 `.env` 永不提交。Repository 只保存範本、變數名稱與 Secret Manager 的非敏感 metadata。
