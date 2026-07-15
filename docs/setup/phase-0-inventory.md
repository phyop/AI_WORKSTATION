# Phase 0 Inventory

> 不要記錄金鑰、Token、帳號、外部 IP 或家庭網路敏感資訊。

- [x] 作業系統與版本：Windows 11（實際 build 請於部署主機確認）
- [x] 裝置名稱：`<host>`（範例名稱 `ai-node-laptop-01`；改名需重開機）
- [x] CPU：12th Gen Intel Core i9-12900H，20 logical processors
- [x] RAM：約 63.7 GiB
- [x] GPU：NVIDIA GeForce RTX 3060 Laptop GPU；Intel Iris Xe Graphics
- [x] 可用磁碟空間：C: 約 557.7 GiB / 930.3 GiB；D: 約 971.2 GiB / 1863.0 GiB
- [x] 網路連線方式：Intel Wi-Fi 6E AX211（盤點時連線中）；另有 VirtualBox Host-Only Adapter
- [x] 可長時間插電：偵測到筆電電池；實際散熱、充電上限與長時間插電條件仍需人工確認
- [x] 插電時自動睡眠行為：AC 與 DC 的 `STANDBYIDLE` 均為 `0`（永不自動睡眠）
- [ ] 是否有固定區域網路 IP：需檢查路由器 DHCP reservation；不在 Git 記錄實際 IP
- [ ] 是否可設定路由器：需由使用者確認
- [x] 時區：Taipei Standard Time（UTC+08:00）
- [x] 系統時間同步：已於 2026-07-12 16:05:56 成功同步 `time.windows.com,0x9`；Leap Indicator 無警告

盤點日期：2026-07-12（Asia/Taipei）。硬體與系統資料由本機唯讀查詢取得；未收集外部 IP、Wi-Fi 密碼或憑證。

## V1 遠端連線決策

- [x] VPN Overlay 優先
- [x] SSH Public Key 驗證
- [x] 不直接向 Internet 公開 SSH Port
