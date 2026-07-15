# Security

## Public Documentation Rules

Do not publish:

- real hostnames or Windows account names;
- home-directory paths or local drive paths;
- IP addresses, SSH aliases, or host-key fingerprints;
- private keys, OAuth files, tokens, cookies, or `.env` files;
- raw diagnostic logs that contain machine identifiers.

Use placeholders such as `<host>`, `<standard-user>`, `<project-root>`, `<user-home>`, and RFC 5737 documentation IP addresses.

## Access Model

- Use a standard account for development and agent work.
- Reserve administrator access for explicit maintenance tasks.
- Prefer VPN-first access before exposing SSH.
- Disable or restrict password authentication after public-key authentication is validated.
- Keep final approval for account-changing or network-changing operations with the human operator.

## Reporting

Open an issue only with redacted reproduction details. Do not attach raw logs unless they have been reviewed and scrubbed.
