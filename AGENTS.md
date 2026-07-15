# Agent Guidance

This repository describes a security-sensitive workstation setup. Treat every local value as potentially identifying unless it is already a neutral placeholder.

## Rules

- Do not commit secrets, tokens, cookies, private keys, `.env` files, browser exports, or runtime reports.
- Do not publish real account names, hostnames, IP addresses, local paths, SSH aliases, host-key fingerprints, or raw logs.
- Use `<host>`, `<standard-user>`, `<project-root>`, `<user-home>`, and similar placeholders.
- Prefer read-only diagnostics before system changes.
- Require human approval before administrative changes, account changes, network exposure, or GitHub visibility changes.
- Keep public documentation in English.

## Validation

Run repository checks after edits:

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify-repository.ps1
git diff --check
```
