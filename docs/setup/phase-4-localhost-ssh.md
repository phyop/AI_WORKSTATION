# Phase 4: localhost SSH automation key

## Purpose

Allow the existing Codex session in the maintenance profile to execute terminal work as the dedicated standard user without repeatedly switching Windows sessions or storing a Windows password.

## Implemented configuration

- Target account: `ai_non_Admin_260712`
- SSH alias: `ai_SSH_Client_260712`
- Endpoint: `127.0.0.1`
- Key type: Ed25519
- Public-key fingerprint: `SHA256:b4EPQFbnEqAEQyCVZFE7Ea3NKX5LvixjHhMNeRqEU5k`
- Private-key location: maintenance-profile `.ssh` directory, protected by Windows ACL
- Authorized-key source restriction: `127.0.0.1` and `::1` only
- Disabled capabilities: agent forwarding, port forwarding, X11 forwarding, and user RC commands
- SSH client behavior: batch mode, explicit identity, strict host-key checking, and all forwarding cleared
- OpenSSH inbound firewall rule: disabled

The private key is intentionally not committed to Git. The repository contains only the public-key bootstrap and operational metadata.

## Security exception

This localhost-only automation key has no passphrase so unattended Codex commands can run. Risk is limited by all of the following controls:

- the key grants access only to the non-administrator account;
- the server accepts this key only from loopback addresses;
- the private key has a restrictive Windows ACL;
- forwarding features are disabled on both the authorized key and client alias;
- the network-facing OpenSSH firewall rule remains disabled.

This key is separate from personal, GitHub, mobile-device, and recovery keys. Do not reuse it for another host or account.

## Verified results

- Public-key authentication succeeded without a password prompt.
- Remote identity: `TXAR\ai_non_admin_260712`.
- Remote host: `TXAR`.
- Administrator-role check: `False`.
- Git is available in the SSH session: `git version 2.54.0.windows.1`.
- Python is not currently available in the SSH session and remains a Phase 8 task.

## Daily command

```powershell
ssh ai_SSH_Client_260712
```

Codex can execute a single command without opening an interactive shell:

```powershell
ssh ai_SSH_Client_260712 "git --version"
```

## Remaining Phase 4 work

- 1Password App `8.12.28.25` is installed for the standard account.
- 1Password CLI `2.34.1` is installed for the standard account.
- Create the separate mobile-to-workstation key in 1Password.
- Record its public fingerprint and non-secret inventory metadata.
- Verify recovery and annual review procedures.
- Keep private keys and Windows credentials out of Git.
