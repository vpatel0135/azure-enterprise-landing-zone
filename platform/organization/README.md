# Organization layer

This Terraform root deploys the accepted archetype-based management-group hierarchy and places subscriptions according to either the `lab` or `enterprise` profile.

It also assigns the first organizational Azure Policy initiative at `alz-example`. The initial release audits:

- resources outside the approved Azure locations; and
- taggable resources missing any key from the accepted seven-tag metadata contract.

Both controls begin in audit mode. There are no remediation identities or automatic changes, and location enforcement is not promoted to deny until compliance evidence has been reviewed.

## Profiles

- `lab` places one existing subscription directly beneath `alz-example`. The subscription intentionally represents several platform and workload responsibilities, so the lab does not claim subscription-level isolation.
- `enterprise` requires distinct Management, Connectivity, web-portfolio production, and web-portfolio non-production subscriptions. Optional Identity and Sandbox subscriptions can be supplied when needed.

Subscription placement is a governed move because inherited policy and access can change. Always inspect the plan before applying it.

## Prerequisites

The deploying identity needs permission to create management groups beneath the tenant root and move the supplied subscriptions. Subscription `Owner` alone is not sufficient. Tenant-root access should be granted deliberately and removed when bootstrap work is complete.

## Initialize

1. Copy `terraform.tfvars.example` to the ignored `terraform.tfvars` and replace all placeholders.
2. Copy `backend.hcl.example` to the ignored `backend.hcl`.
3. Authenticate to the intended tenant and verify the active subscription.
4. Run `terraform init -backend-config=backend.hcl`.
5. Run `terraform plan -out organization.tfplan` and review every parent relationship and subscription move.
6. Apply only an approved saved plan.

The remote state is isolated in the `organization` container with the key `organization.tfstate`.

The machine-readable policy inventory is stored in `policy/catalog.json`. Built-in versions are observed and reviewed rather than updated implicitly.
