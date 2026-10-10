# Contributing

This repository uses short-lived branches and pull requests into `main`.

## Before opening a pull request

1. Run `terraform fmt -recursive`.
2. Run `terraform init -backend=false` and `terraform validate` in each changed Terraform root or module.
3. Run relevant `terraform test` suites.
4. Review the plan for unrelated or destructive changes when Azure-backed planning is available.
5. Confirm that no state, plan files, credentials, tenant IDs, subscription IDs, or populated personal variable files are included.

Routine deployments must not use Terraform resource targeting. Use `-target` only for documented recovery from an exceptional condition.

## Architecture changes

Changes that reverse an accepted architecture decision require a new ADR. Do not silently rewrite the reason for an accepted decision.
