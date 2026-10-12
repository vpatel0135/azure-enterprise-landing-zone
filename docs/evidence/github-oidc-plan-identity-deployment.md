# GitHub OIDC plan identity deployment evidence

## Outcome

The read-only platform planning identity was deployed on 2026-10-12 through the privileged identity Terraform state. A post-deployment plan reported no changes.

The deployment created:

- Microsoft Entra application `id-alz-platform-plan`;
- its service principal;
- one GitHub federated identity credential; and
- Reader plus per-container state-reader assignments.

The credential accepts tokens only from `vpatel0135/azure-enterprise-landing-zone` on `refs/heads/main`, with GitHub's official issuer and the Azure token-exchange audience. No password, certificate, or client secret exists.

## Authorization boundary

- Reader is scoped to the `alz-example` management group.
- Storage Blob Data Reader is scoped separately to the `organization`, `management`, and `connectivity` containers.
- The identity has no Contributor, policy-write, role-assignment, Owner, or access-administrator permission.
- Bootstrap and identity state are excluded from automation.

The proposed write-capable apply identity was not deployed. Creating a persistent GitHub trust with subscription Contributor and management-group write roles requires a separate explicit privileged-access approval even though the design is recorded in Terraform. `enable_platform_apply_identity` therefore defaults to `false`.

## GitHub configuration status

The manual `Platform plan` workflow is defined and requests `id-token: write` only for its Azure-authenticated job. It suppresses full plan output and publishes only whether changes exist so personal tenant identifiers do not appear in public logs.

The workflow has not yet completed end-to-end because the GitHub web session needed to create repository variables is not authenticated. It remains manual-only so pushing the workflow does not create a known failed run. The missing variables and recovery steps are listed in the OIDC bootstrap runbook.

## Validation performed

- Terraform validation succeeded.
- The identity tests verified distinct plan/apply designs and the exact protected apply subject.
- TFLint completed without findings.
- Live Terraform refresh reported zero drift after Azure role-ID normalization.
