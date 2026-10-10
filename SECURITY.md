# Security Policy

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or exposed credential. Use GitHub's private vulnerability reporting feature for this repository.

If a credential is exposed, revoke or rotate it immediately before removing it from Git history. Removing a value from the latest commit does not invalidate the credential or erase it from earlier commits.

## Supported code

Security fixes target the current `main` branch. This portfolio repository does not currently publish supported release branches.

## Sensitive material

Never commit Terraform state or plan files, populated `.tfvars` files, access tokens, client secrets, private keys, tenant-specific contact details, or personal Azure identifiers.
