# AI Workstation

以安全、可重建、平台無關為原則的遠端 AI 工程工作站。

## 文件

- `ROADMAP.md`：建置階段與目前進度
- `ARCHITECTURE.md`：系統邊界與元件
- `SECURITY.md`：安全基線與通報方式
- `docs/setup/phase-0-inventory.md`：主機盤點清單
- `docs/decisions/`：架構決策紀錄（ADR）

## 原則

- Git 是設定與文件的唯一真實來源。
- Secret 永不進入 Git。
- 遠端存取採 VPN-first，不直接公開 SSH Port。
- 所有具風險的系統與 GitHub 操作保留人工確認。

## 開始

1. 完成 `docs/setup/phase-0-inventory.md`。
2. 閱讀 `SECURITY.md`。
3. 依 `ROADMAP.md` 循序執行並記錄驗收結果。
