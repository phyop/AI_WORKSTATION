# Threat Model v1

## Assets

- workstation access;
- GitHub repository integrity;
- SSH keys and credentials;
- local development files;
- public documentation reputation.

## Threats

| Threat | Risk | Control |
| --- | --- | --- |
| Secret committed to Git | Credential exposure | `.gitignore`, examples only, repository validation |
| SSH exposed too early | Remote attack surface | VPN-first access, staged firewall changes |
| Agent runs as administrator | Excessive privilege | standard user for agent work |
| Raw logs published | Host or account leakage | summarize logs and redact identifiers |
| Password captured in history | Account compromise | secure prompts and human-only entry |

## Assumptions

- Public documentation must be safe for broad readers.
- Private implementation details can exist outside the public repository.
- Human approval remains required for high-risk actions.
