# Architecture

The workstation is designed around separated trust boundaries.

```mermaid
flowchart LR
  Remote[Remote operator] --> PrivateNetwork[VPN or private network]
  PrivateNetwork --> SSH[OpenSSH on workstation]
  SSH --> StandardUser[Standard development user]
  StandardUser --> DevTools[Git, Python, Codex, editors]
  AdminUser[Administrator user] --> SystemChanges[Installers, services, recovery]
  Repo[GitHub repository] --> Documentation[Scripts, ADRs, validation notes]
  SecretStore[Secret manager] -. not committed .-> SSH
```

## Boundaries

- The standard user performs normal development and agent work.
- The administrator user is reserved for installation, recovery, and controlled system changes.
- Secrets are stored outside Git.
- Public documentation uses placeholders for host, account, path, and network identifiers.
- Remote access should be protected by a VPN or private overlay before SSH is reachable from outside the local machine.
