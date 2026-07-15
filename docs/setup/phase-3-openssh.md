# Phase 3 — Windows OpenSSH Server

## Current status

- `OpenSSH.Server` is **Installed**.
- `sshd` is **Running** with **Automatic** startup.
- The built-in inbound firewall rule is disabled until a dedicated public key is verified.
- Local TCP/SSH protocol response is verified; unauthenticated BatchMode login is correctly rejected.
- CBS reports a post-install pending reboot signal; restart acceptance remains outstanding.
- The FoD repair-source registry change is **not needed** and was not applied.

Next on `<host>`:

```powershell
# Phase 4: install and verify the dedicated public key first.
# Do not enable the inbound firewall rule yet.
```

See `docs/troubleshooting/openssh-capability-stuck.md` for the historical installation diagnosis.

## Safe rollout

1. Complete the first interactive sign-in for `ai_standard_user`.
2. Install and verify the dedicated SSH public key in Phase 4.
3. Harden `sshd_config` and disable password login.
4. Enable only the scoped inbound firewall rule after key verification.
5. Reboot and verify automatic service recovery and logging.

The install script intentionally keeps the OpenSSH inbound firewall rule disabled. This prevents network password login while the account has no verified SSH key and the VPN boundary is not ready.

## Acceptance status

- [x] OpenSSH Server capability installed
- [x] `sshd` starts and uses Automatic startup
- [x] Inbound firewall remains disabled before key verification
- [x] Local TCP and SSH protocol response succeeds
- [ ] Local SSH key login succeeds
- [ ] Authorized VPN/LAN client login succeeds
- [ ] Password login is disabled
- [ ] Restart and logging behavior verified
