# AI Engineering Platform Roadmap（V1–V4）

## 1. 專案定位

本專案的目標不是建立一台綁定特定作業系統、特定 AI 供應商或特定硬體的「AI 電腦」，而是打造一套：

- 可替換（Replaceable）
- 可擴充（Extensible）
- 可重建（Reproducible）
- 平台中立（Platform Agnostic）
- 廠商中立（Vendor Neutral）
- 具備人工審核（Human-in-the-loop）
- 可逐步自動化（Progressive Automation）

的個人 AI Engineering Platform。

初期以現有筆電作為主要節點，未來可加入 Mac mini、Linux Server、GPU Worker、NAS 或雲端節點。

---

## 2. 核心設計原則

1. **Platform Agnostic**
   不綁定 Windows、macOS 或 Linux。

2. **Vendor Neutral**
   不綁定 OpenAI、Anthropic、Google、Microsoft 或任何單一模型供應商。

3. **Replaceable**
   Codex、Cursor、Claude、Gemini、Local LLM 與硬體節點都應可替換。

4. **Extensible**
   可增加新的 Agent、模型、工作流程、執行節點與儲存服務。

5. **Git as Source of Truth**
   設定、文件、Prompt、Workflow、Policy、決策與安裝腳本均納入版本控制。

6. **Secrets Never in Git**
   SSH Private Key、API Key、Token、密碼與正式環境憑證不得提交至 Git。

7. **Human-in-the-loop**
   刪除檔案、推送正式分支、部署、修改權限、執行高風險命令等操作需保留人工批准。

8. **Observable**
   Agent 選擇、執行結果、錯誤、切換原因與重要操作需保留記錄。

9. **Reproducible**
   更換電腦或新增節點時，應能透過文件與腳本重建環境。

10. **Progressive Automation**
    先人工路由，再建立規則路由，最後才逐步自動化。

---

## 3. 目標架構

```text
手機 / 平板 / 電腦
        │
        ▼
SSH / Web UI / IDE / Terminal
        │
        ▼
Agent Router
        │
 ┌──────┼────────┬────────┬──────────┐
 │      │        │        │          │
Codex  Cursor  Claude   Gemini   Local LLM
        │
        ▼
Execution Nodes
 ┌─────────────┬──────────────┬──────────────┐
 │             │              │              │
Laptop      Mac mini      Linux Server    GPU Worker
 │             │              │              │
Git / Python / Docker / RAG / Automation / Model Runtime
```

---

# V1 — Secure Remote AI Workstation

## 目標

建立一個可從手機安全連線、即使裝置處於鎖定畫面仍可使用、並可透過 Git 重建與管理的遠端 AI 開發環境。

## 核心成果

- 可透過 SSH 從手機連入主要節點。
- 使用 SSH Key，而非一般密碼登入。
- 以 1Password 為第一優先的人工憑證管理工具。
- 建立安全的 GitHub 存取方式。
- 可遠端執行 Git、Python、Shell 與 Codex CLI。
- 保留 Cursor 作為同位階開發工具，不強制前後流程。
- 建立 Agent Pool 使用紀錄。
- 建立 Repository、文件、設定範本與驗收清單。
- Windows、macOS、Linux 以相同結構管理，但 V1 只需完成目前主要節點。

## V1 不包含

- 自動 Agent Router。
- Local LLM 正式部署。
- Docker 服務平台。
- 自動喚醒 GPU Worker。
- 對外公開服務。
- 完全無人值守的高風險操作。

## V1 完成定義

- 手機可使用 SSH Key 登入。
- 筆電鎖定後 SSH 仍可工作。
- 裝置休眠、關機、網路中斷時有明確處理方式。
- Codex CLI 可在 SSH Session 中正常執行。
- Git Clone、Commit、Pull、Push 可正常完成。
- GitHub Repository 中不存在任何 Secret。
- 可依文件在另一台裝置重建基本環境。
- 完成基礎安全檢查與回復方案。

---

# V2 — Local AI and Container Platform

## 目標

加入 Docker、Local LLM、GPU 使用與服務化能力，將工作站升級為可持續執行 AI 工作負載的平台。

## 核心成果

- 建立 Docker 或相容容器環境。
- 建立跨平台 Compose 設定。
- 部署 Ollama、llama.cpp 或其他本地模型執行環境。
- 驗證 RTX 3060 GPU 推論。
- 建立模型下載、版本、快取與儲存規範。
- 建立簡易 Web UI 或 API。
- 建立基礎 RAG 元件。
- 將服務設定、啟停腳本與健康檢查納入 Git。
- 建立 Local AI 與雲端 AI 的切換規則。

## 建議節點分工

```text
主要控制節點
├── SSH
├── Git
├── Agent Router Prototype
├── Web UI
├── RAG Metadata
└── 輕量模型

GPU 節點
├── CUDA
├── Local LLM
├── Embedding
├── Image / Vision Inference
└── 模型測試
```

## V2 完成定義

- 可用單一指令啟動主要 AI 服務。
- 本地模型可透過 GPU 或 CPU 執行。
- 服務具備日誌、健康檢查與停止方式。
- 模型與資料不直接混入 Source Repository。
- 至少完成一個實用 Local AI Workflow。

---

# V3 — Rule-based Agent Router

## 目標

將「由人判斷該使用 Codex、Cursor、Claude、Gemini 或 Local LLM」的經驗，轉換為可追蹤、可維護的路由規則。

## 核心成果

- 建立標準 Task Schema。
- 建立 Agent Capability Profile。
- 建立 Rule-based Routing。
- 支援 Preferred Agent 與 Fallback Agent。
- 記錄任務、Agent、結果、錯誤與人工評分。
- 建立成本、速度、品質與隱私維度。
- 建立人工批准節點。
- 建立 Agent 切換 SOP。
- 建立 Router CLI 或簡易 Web UI。

## 路由範例

```yaml
routing_rules:
  repository_analysis:
    preferred:
      - codex
      - claude
    fallback:
      - cursor

  incremental_ide_edit:
    preferred:
      - cursor
      - codex

  google_workspace:
    preferred:
      - gemini
      - codex

  private_offline_task:
    preferred:
      - local_llm

  long_document_analysis:
    preferred:
      - claude
      - gemini
```

## V3 完成定義

- 使用者輸入任務後，Router 可提出 Agent 建議與理由。
- 可記錄實際選擇與結果。
- 可執行至少一種 Agent 的半自動派送。
- 失敗後可依規則建議替代 Agent。
- 高風險操作仍需人工批准。

---

# V4 — Personal AI Cloud and Automated Agent Router

## 目標

建立跨節點、可自動派送、可失敗切換、可觀察、可審核的個人 AI Cloud。

## 核心成果

- 自動任務分類。
- 自動 Agent 選擇。
- 自動 Fallback。
- 多 Agent 結果比較。
- 自動測試與品質評分。
- 成本、Token、時間與硬體使用控制。
- Mac mini 作為常駐控制節點的可能架構。
- RTX 3060 筆電作為 GPU Worker。
- 支援 Linux Server、NAS 或雲端節點。
- 支援排程、事件觸發與長時間工作。
- 建立完整 Audit Log。
- 建立權限、Policy 與 Approval Workflow。
- 建立備份、災難復原與節點替換機制。

## 可能的最終架構

```text
手機 / Web / IDE
        │
        ▼
Mac mini Control Node
├── Agent Router
├── Scheduler
├── API Gateway
├── RAG / Metadata
├── Audit Log
├── Secret Integration
└── Monitoring
        │
        ├── RTX 3060 GPU Worker
        ├── Linux Worker
        ├── Cloud AI APIs
        ├── Codex
        ├── Cursor
        ├── Claude
        ├── Gemini
        └── Local LLM
```

## V4 完成定義

- Router 可自動派送低風險任務。
- 任務失敗可依 Policy 自動切換 Agent。
- 高風險操作保留人工批准。
- 節點離線時可重新排程或切換。
- 任一 AI 供應商失效時，平台仍能以其他工具運作。
- 任一硬體節點更換後，可依 Git 中設定重建。
- 平台具備可展示的操作介面、文件與案例。

---

# 4. 建議 Repository 結構

```text
ai-engineering-platform/
├── README.md
├── ROADMAP.md
├── ARCHITECTURE.md
├── SECURITY.md
├── CHANGELOG.md
├── CONTRIBUTING.md
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
│   ├── shell/
│   └── editors/
│
├── agents/
│   ├── codex/
│   ├── cursor/
│   ├── claude/
│   ├── gemini/
│   └── local-llm/
│
├── router/
│   ├── rules/
│   ├── schemas/
│   ├── evaluators/
│   └── logs/
│
├── prompts/
├── workflows/
├── scripts/
├── tests/
├── docker/
├── local-llm/
│
└── docs/
    ├── setup/
    ├── operations/
    ├── troubleshooting/
    ├── security/
    └── decisions/
```

---

# 5. Architecture Decision Records

建議從一開始建立 ADR：

```text
docs/decisions/
├── ADR-001-platform-agnostic.md
├── ADR-002-vendor-neutral.md
├── ADR-003-agent-pool-model.md
├── ADR-004-git-as-source-of-truth.md
├── ADR-005-secrets-management.md
├── ADR-006-human-in-the-loop.md
├── ADR-007-progressive-agent-router.md
└── ADR-008-future-mac-mini-control-node.md
```

---

# 6. 里程碑摘要

| 版本 | 核心主題 | 主要成果 |
|---|---|---|
| V1 | Secure Remote Workstation | SSH、Git、Codex CLI、文件化、可重建 |
| V2 | Local AI Platform | Docker、GPU、Local LLM、RAG、服務化 |
| V3 | Rule-based Agent Router | Agent Profile、路由規則、Fallback、紀錄 |
| V4 | Personal AI Cloud | 跨節點、自動派送、審核、監控、災難復原 |

---

# 7. 當前優先順序

目前只實作 V1。

V2～V4 的規劃用途是：

- 避免 V1 做出未來無法延伸的設計。
- 提前保留跨平台與多 Agent 能力。
- 確保所有 V1 產出可成為後續版本基礎。
- 將整個建置過程累積為 GitHub、Medium、履歷與顧問作品。
