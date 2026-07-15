# Codex dual-account operating model

## Goal

Use Codex in both the administrator profile and the dedicated standard-user profile without repeatedly copying long commands between Windows sessions.

## Accounts

- Computer name: `<host>`
- Administrator profile: installation, system maintenance, and recovery only
- Standard profile: `ai_non_Admin_260712`
- SSH display alias: `ai_SSH_Client_260712`

## Security boundary

Codex and its sign-in state are registered separately for each Windows profile. Both profiles may sign in with the same ChatGPT account, but Windows passwords, application tokens, configuration directories, and SSH private keys must not be copied between profiles.

Do not run Codex as a privileged cross-account service and do not store the standard account password in a script, scheduled task, repository, or credential file.

## One-time standard-profile setup

1. Sign in to `ai_non_Admin_260712`.
2. On the Public Desktop, double-click `Setup AI Standard User Tools`.
3. Sign in to 1Password once.
4. Install the official OpenAI Codex app from the Microsoft Store window opened by the setup.
5. Open Codex and sign in with the existing ChatGPT account.

The setup script refuses to run under another username or with administrator privileges. It stores no passwords or tokens.

## Daily operation after Phase 4

Create a dedicated local SSH key and authorize it only for `ai_non_Admin_260712`. Once key authentication is verified, the current Codex session can execute standard-user work through localhost SSH:

```powershell
ssh ai_non_Admin_260712@127.0.0.1
```

This avoids Windows sign-out/sign-in for terminal work while preserving the least-privilege boundary. GUI-only authentication prompts may still require a one-time interaction in the standard profile.

Keep the OpenSSH inbound firewall rule disabled until local key authentication and host-key verification are complete.
