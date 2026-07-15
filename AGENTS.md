# AGENTS.md

## Cursor Cloud specific instructions

### 專案現況（重要）

此 Repository 目前為**純文件 / 規劃倉庫（documentation-only）**，只包含兩份繁體中文規劃文件：

- `AI_WORKSTATION_V1_IMPLEMENTATION_PLAN.md` — AI Workstation V1 實作計畫
- `AI_ENGINEERING_PLATFORM_ROADMAP_V1_V4.md` — 平台 V1–V4 路線圖

倉庫中**沒有任何原始碼、套件清單（`package.json`、`requirements.txt`、`pyproject.toml` 等）、鎖定檔、`Dockerfile`、`docker-compose.yml`、`Makefile` 或 `.cursor/environment.json`**。因此目前：

- **沒有需要安裝的相依套件** → 開機更新腳本實際上是 no-op。
- **沒有 lint / test / build 指令** 可執行。
- **沒有可啟動的服務或應用程式**；不適用 GUI 手動測試。

文件描述的 SSH Server、VPN Overlay、Codex CLI 等，都是**未來 V1 才要建置的規劃內容**，尚未實作。

### 未來若開始實作程式碼

文件規劃 V1 會是 Python 專案（`pyproject.toml` / `src/` / `tests/`，環境管理器可能為 uv/venv/pip）搭配 Node.js（供 Codex CLI 使用）。屆時：

- 依實際出現的套件清單更新開機更新腳本（例如 `npm install`、`uv sync` 或 `pip install`）。
- 依實際新增的指令執行 lint / test / build。

### 環境已具備的工具

基礎映像已內建 `git`、`python3`、`node`、`npm`、`gh`，符合文件對 V1 執行環境的預期，可直接使用。
