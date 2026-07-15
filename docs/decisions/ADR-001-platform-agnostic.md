# ADR-001: Keep the Workstation Pattern Platform-Agnostic

## Decision

The workstation architecture must separate platform-neutral policy from platform-specific bootstrap scripts.

## Rationale

Windows is the first implementation target, but the security model should also apply to macOS and Linux. Shared rules live in documentation and ADRs; operating-system details live under `bootstrap/<platform>/`.
