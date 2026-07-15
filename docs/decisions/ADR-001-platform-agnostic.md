# ADR-001: Platform Agnostic

Status: Accepted

工作流程與文件以 Windows、macOS、Linux 可替換為原則；平台專屬實作分置於 `bootstrap/<platform>/`，不讓核心架構依賴單一作業系統。
