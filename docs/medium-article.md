# Building a Secure Windows AI Workstation with Git, OpenSSH, and Human Approval Gates

## Title options

1. Building a Secure Windows AI Workstation with Git, OpenSSH, and Human Approval Gates
2. From Laptop to AI Workstation: A Privacy-Safe Windows Engineering Setup
3. OpenSSH, DISM, and Git: Building a Remote AI Engineering Workstation Safely
4. Why an AI Workstation Needs Security Gates Before Remote Access
5. Turning a Windows Laptop into a Reproducible AI Engineering Environment

## The starting point

The project began with a simple goal: make a Windows laptop usable as a remote AI engineering workstation. At first glance, that sounds like a tooling checklist. Install Git, install Python, enable OpenSSH, add an editor, and connect from another device.

That would have been the fast path. It also would have been the wrong path.

Remote access, long-running machines, AI agents, credentials, and administrative tools create a shared risk surface. A useful workstation is not just a machine that accepts commands from somewhere else. It is a system where the account boundary is clear, secrets stay out of Git, recovery remains possible, and every risky action leaves enough evidence to audit later.

So the first milestone was not opening port 22. It was building a repository that could explain the workstation safely.

## Making Git the source of truth

The repository became the public source of truth for everything non-sensitive:

- architecture notes;
- setup phases;
- ADRs;
- PowerShell bootstrap scripts;
- threat model notes;
- troubleshooting records;
- validation scripts;
- publication copy.

The public version intentionally avoids real local values. Hostnames, account names, home paths, IP addresses, SSH aliases, host-key fingerprints, private keys, and raw logs are replaced with placeholders such as `<host>`, `<standard-user>`, `<project-root>`, and `<user-home>`.

This mattered because public documentation is itself a product surface. A technically useful article can still be unsafe if it leaks enough details to identify the machine or account behind it.

## Separating administrator work from agent work

The next design choice was least privilege.

The workstation uses a standard development account for SSH, Git, Python, Codex, and normal engineering work. Administrator access is kept separate for installation, system recovery, service configuration, and other maintenance tasks.

That split gives AI agents a smaller operating boundary. They can help generate scripts, compare Git state, read diagnostics, and validate documentation. They should not receive blanket administrator power. Account creation, firewall changes, GitHub visibility changes, and public publishing remain human-approved actions.

Even the standard-user setup script reflects that model. It reads the initial password locally through a secure prompt instead of putting it in chat, shell history, or a command line.

## Rolling out OpenSSH in phases

OpenSSH Server was the most important capability, but it also needed the strongest gate.

The rollout strategy was:

1. install the Windows capability;
2. configure and start the service;
3. verify local service and protocol behavior;
4. keep inbound firewall exposure closed;
5. add public-key authentication later;
6. only then restrict password authentication and open access through a private network boundary.

The key idea is that "installed" and "safely reachable" are different states. A workstation can validate local SSH behavior before it exposes anything externally.

## When Windows servicing looked stuck

The hardest debugging moment came during OpenSSH installation. `Add-WindowsCapability` appeared to run for a long time without producing an `sshd` service. A tempting response would have been to rerun installation commands or start changing Windows Update policy immediately.

Instead, the project paused and collected evidence.

Read-only diagnostics checked the optional capability state, DISM and CBS signals, pending reboot indicators, service state, and update-source policy. The evidence suggested that Windows servicing had not necessarily failed; it might still be completing delayed work.

That distinction changed the response. The project avoided stacking repair attempts on top of an uncertain servicing state. After a later check showed the OpenSSH Server capability installed, the right action was simple: configure `sshd`, start the service, keep the firewall closed, and record the result.

The lesson was blunt: a timeout is not a root cause. On Windows, servicing can be slow enough that patience and diagnostics are safer than repeated mutation.

## Why a refused login was success

One validation result looked negative at first: unauthenticated batch login returned `Permission denied`.

At that phase, it was exactly the desired result.

The service was installed. Local TCP and SSH protocol behavior worked. The daemon responded. But no public key had been installed yet, and external inbound exposure remained closed. Refusing login proved that the workstation had not accidentally become a usable password-authenticated remote target.

Security work often has this shape. The goal is not to make every operation succeed immediately. The goal is to make only the intended operation succeed at the intended phase.

## The AI collaboration model

This project was AI-assisted, but not autonomous.

AI helped structure the roadmap, write privacy-safe documentation, generate PowerShell scripts, inspect Git state, compare branches, identify risky publication details, and summarize diagnostics. The human operator approved elevation, entered passwords locally, decided when to reboot, and controlled publication.

That is the model I want for sensitive workstation automation: AI accelerates preparation and verification; humans retain authority over credentials and side effects.

## Pitfalls to avoid

- Do not publish real hostnames, account names, IP addresses, local paths, or SSH fingerprints.
- Do not store private keys, tokens, cookies, or `.env` files in Git.
- Do not run agents as administrator by default.
- Do not expose SSH before key-based authentication and network boundaries are ready.
- Do not treat a Windows servicing timeout as proof of failure.
- Do not combine diagnostics, repair, firewall changes, and service changes in one unreviewed script.
- Do not claim an AI workflow was fully autonomous when human approval was required.

## What the repository demonstrates

The public repository demonstrates a reusable pattern:

- start with documentation and threat modeling;
- make Git the source of truth for non-sensitive artifacts;
- separate standard development work from administrator maintenance;
- install remote access in phases;
- validate before exposing;
- keep public writing useful without leaking private details.

The result is less dramatic than "one command builds a workstation." It is also much safer. A real AI engineering workstation should be boring in the best possible way: explicit, auditable, recoverable, and careful about what it reveals.

## SEO

- **SEO title:** Build a Secure Windows AI Workstation with Git, OpenSSH, and Human Approval Gates
- **Meta description:** A privacy-safe case study on building a Windows AI engineering workstation with Git, PowerShell, OpenSSH, least privilege, DISM/CBS troubleshooting, and human-approved security gates.
- **URL slug:** `secure-windows-ai-workstation-git-openssh-human-approval`

## Tags

Windows, OpenSSH, DevOps, AI Engineering, Cybersecurity
