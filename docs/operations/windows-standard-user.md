# Windows Standard User

## Identity

- Computer name: `<host>`
- Local standard user: `ai_standard_user`
- SSH Client alias: `ai_ssh_client`
- Administrator account remains the installation, maintenance, and recovery path.

The standard user is reserved for SSH, Git, Python, Codex, and routine development. It must not be added to the local Administrators group.

Created and verified on 2026-07-12: enabled, password required, member of the built-in Users group, and not a member of Administrators. First interactive sign-in remains an acceptance test.

## Creation

Run `bootstrap/windows/create-ai-standard-user.ps1` from an elevated PowerShell. Enter the initial password only in the local secure prompt; never place it in Git, shell history, logs, or chat.

## SSH alias

`configs/ssh/client_config.example` is a client-side template. Do not deploy it until Phase 3 establishes the real SSH Server and Phase 4 establishes the dedicated key. Verify the host key fingerprint before the first connection.
