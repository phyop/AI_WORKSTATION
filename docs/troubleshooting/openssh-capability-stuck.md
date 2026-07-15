# Troubleshooting: OpenSSH Capability Appears Stuck

Windows optional capability installation can appear stalled while DISM and CBS continue processing. Treat a timeout as a diagnostic signal, not immediate proof of failure.

## Symptoms

- `Add-WindowsCapability` remains in a running state for longer than expected.
- `sshd` is not yet present as a service.
- servicing state suggests a pending reboot or delayed completion.

## Safe Response

1. Stop repeated installation attempts.
2. Run read-only diagnostics.
3. Check capability state, service state, Windows Update source policy, and pending reboot indicators.
4. Reboot only after human approval.
5. Re-check state before applying any repair script.

## Lesson

The safest recovery path is evidence-first. A delayed installation may complete after servicing catches up. Repair scripts should require explicit approval and should not combine diagnosis with unrelated changes.
