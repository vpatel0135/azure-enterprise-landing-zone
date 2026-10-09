# ADR-0003: Separate Human, Deployment, Workload, and Emergency Identities

- **Status:** Accepted
- **Date:** 2026-10-09
- **Decision owner:** Repository maintainer

## Context

The landing zone has four materially different identity use cases:

1. people administering the Azure platform;
2. people operating application landing zones;
3. CI/CD systems deploying infrastructure and applications; and
4. Azure resources accessing other Azure services at runtime.

Treating these identities alike would create excessive privilege and long-lived credentials. The design must also provide a recovery path if normal identity controls lock administrators out.

Microsoft Entra capabilities vary by license. Security defaults are available without premium licensing, Conditional Access generally requires Microsoft Entra ID P1, and Privileged Identity Management requires an eligible P2 or Entra ID Governance license. The enterprise target can specify premium controls, but the lab profile must not pretend they are available at no cost.

## Decision drivers

- Enforce least privilege and separation of duties.
- Avoid direct role assignments to individual users for routine access.
- Avoid long-lived client secrets in GitHub or Terraform configuration.
- Make production deployment approval distinct from plan generation.
- Keep workload teams able to operate their own subscriptions without changing inherited policy.
- Provide auditable elevation for highly privileged roles.
- Preserve emergency tenant access without depending on normal authentication paths.
- Clearly distinguish free controls from licensed enterprise capabilities.

## Decision

Use Microsoft Entra ID as the identity control plane and use distinct patterns for each identity category.

### Human access

- Assign Azure roles to Microsoft Entra security groups, not directly to ordinary user accounts.
- Create separate groups for platform operations and for each application landing zone.
- Give workload groups roles at subscription or resource-group scope so workload administrators cannot modify management-group policy assignments.
- Use built-in Azure roles wherever they provide sufficient permissions. Introduce a custom role only when its required actions and exclusions are documented and tested.
- Separate normal work from privileged administration. The enterprise profile uses dedicated administrative accounts or an equivalently controlled privileged-access workflow.
- Require phishing-resistant MFA for privileged administrators in the enterprise target.

Proposed group model:

| Group | Scope | Standing access | Elevated access |
|---|---|---|---|
| `sg-alz-platform-readers` | `alz-example` | Reader | None |
| `sg-alz-platform-operators` | Relevant platform subscriptions | Least-privilege operational roles | Optional controlled elevation |
| `sg-alz-policy-admins` | `alz-example` | Reader | Optional Resource Policy Contributor elevation |
| `sg-alz-access-admins` | Selected platform scopes | Reader | Optional User Access Administrator elevation |
| `sg-webportfolio-prod-readers` | Web-portfolio production subscription | Reader | None |
| `sg-wedding-nonprod-operators` | Wedding non-production resource group | Contributor without role-assignment control | None by default |
| `sg-wedding-prod-operators` | Wedding production resource group | Contributor without role-assignment control | Optional controlled elevation |
| `sg-honeymoon-nonprod-operators` | Honeymoon non-production resource group | Contributor without role-assignment control | None by default |
| `sg-honeymoon-prod-operators` | Honeymoon production resource group | Contributor without role-assignment control | Optional controlled elevation |

Group names are defaults and will be parameterized. No real user names or email addresses belong in committed configuration.

### Privileged Identity Management

PIM is an optional enterprise enhancement rather than a deployment prerequisite. When an organization has Microsoft Entra ID P2 or Entra ID Governance, privileged groups and roles should use just-in-time activation with MFA, justification, short duration, and approval for production-impacting roles.

PIM is a documented optional capability in the `lab` profile. Without an appropriate license, the lab uses the narrowest practical standing assignments, security defaults for baseline protection, and explicit manual review. This is a cost concession, not an equivalent security control.

### CI/CD deployment identities

- GitHub Actions authenticates to Azure using OpenID Connect and a Microsoft Entra federated identity credential.
- No client secret or certificate private key is stored in GitHub.
- Tenant ID, subscription ID, and client ID are configuration identifiers, not authentication secrets, but they are still kept out of the public example values to avoid publishing personal tenant metadata.
- Federated credentials are restricted to the expected repository, branch or GitHub environment, and workflow context.
- Production applies run through a protected GitHub environment with human approval.
- Plan and apply use separate identities. The plan identity receives read access needed to inspect the target; the apply identity receives narrowly scoped write access.
- Platform and website deployments use separate identities and role assignments so compromise of the website pipeline does not grant platform control.

Proposed automation identities:

| Identity | Purpose | Maximum intended scope |
|---|---|---|
| `id-alz-platform-plan` | Validate and plan platform changes | Reader plus policy-specific read permissions |
| `id-alz-platform-apply` | Apply approved platform changes | Required management-group and platform-subscription roles |
| `id-wed-n-plan` / `id-wed-n-apply` | Plan and deploy Wedding non-production | Wedding non-production resource group |
| `id-wed-p-plan` / `id-wed-p-apply` | Plan and deploy Wedding production | Wedding production resource group |
| `id-hny-n-plan` / `id-hny-n-apply` | Plan and deploy Honeymoon non-production | Honeymoon non-production resource group |
| `id-hny-p-plan` / `id-hny-p-apply` | Plan and deploy Honeymoon production | Honeymoon production resource group |

Broad roles might be temporarily necessary during bootstrap. Any bootstrap elevation must be documented, time-bound, and removed or reduced after role assignments and policy resources exist.

### Runtime workload identities

- Use system-assigned managed identities by default when a runtime workload actually needs Azure access and the identity lifecycle should match one resource.
- Use a dedicated user-assigned managed identity per application only when multiple components intentionally need the same stable access or the identity lifecycle must be independent.
- Do not create a runtime identity for a purely static workload that does not access protected Azure services.
- Never share a runtime identity between applications.
- Do not use storage keys, database passwords, or service-principal secrets when managed identity is supported.
- Grant runtime identities data-plane roles at the individual resource or resource-group scope required by the workload.
- Store unavoidable secrets in Azure Key Vault and grant access through Azure RBAC.

### Emergency access

The enterprise target documents the recommendation for at least two cloud-only emergency access accounts:

- use the tenant's `onmicrosoft.com` domain and do not depend on federation;
- hold permanent active Global Administrator because they exist for recovery when normal elevation paths fail;
- use phishing-resistant authentication, stored separately from normal administrator credentials;
- remain excluded only from Conditional Access policies that could prevent emergency use;
- generate alerts for any sign-in or credential change; and
- be tested at least every 90 days with the test recorded.

Emergency credentials, authentication devices, and recovery material are never created or stored by this public repository. The personal lab does not create extra accounts merely for demonstration; it reports the missing enterprise control. The code may deploy monitoring around existing accounts only after their object IDs are supplied privately.

## Authorization boundaries

| Actor | Can manage platform resources | Can change inherited policy | Can deploy website | Can grant access |
|---|---:|---:|---:|---:|
| Platform operator | Yes, within assigned platform scope | Only through elevated policy role | No by default | No by default |
| Policy administrator | No general resource management | Yes, while elevated | No | No |
| Access administrator | No general resource management | No | No | Yes, while elevated and scoped |
| Website non-production operator | No | No | Non-production only | No |
| Website production operator | No | No | Production only while elevated/approved | No |
| Website deployment identity | No | No | Assigned environment only | No |
| Emergency administrator | Yes | Yes | Yes | Yes; emergency use only |

## Options considered

### One service principal with a client secret

Rejected. It combines platform and workload blast radii, creates a long-lived credential, and makes environment-specific access difficult to reason about.

### One GitHub identity for plan and apply

Rejected for the enterprise target. A pull-request plan should not possess the same mutation permissions as an approved production deployment.

### Direct assignments to the repository owner

Rejected as the normal model. They are harder to audit and scale than group-based assignments. The lab may require an existing owner account for initial bootstrap, but steady-state roles remain group-based.

### Require premium Entra features for all deployments

Rejected. PIM and Conditional Access are valuable enterprise controls, but making them mandatory would prevent cost-conscious evaluation. Their absence in the lab is clearly reported as a control gap.

## Consequences

- The design has more identities than a simple demonstration, but each has a narrow and explainable purpose.
- GitHub stores identifiers for login configuration but no Azure authentication secret.
- The enterprise target depends on licensed capabilities for full just-in-time access and Conditional Access.
- Bootstrap remains a sensitive phase and needs a dedicated runbook.
- Emergency access needs manual operational discipline beyond infrastructure as code.
- The website delivery pipeline cannot modify landing-zone governance.

## Implementation guardrails

- Never output access tokens, credentials, or Key Vault secret values from Terraform.
- Mark sensitive Terraform inputs and outputs as sensitive, while recognizing that this does not remove them from state.
- Keep Entra and Azure role assignments in a state boundary protected as highly privileged.
- Pin GitHub Actions to immutable commit SHAs in production workflows.
- Limit workflow `permissions`; grant `id-token: write` only to jobs that authenticate with OIDC.
- Use protected environments for production and restrict federated credential subjects accordingly.
- Fail validation if platform and workload apply identities are configured with the same client ID in the enterprise profile.
- Do not automate emergency-account credentials.

## Validation criteria

This decision will be validated by:

- tests that reject direct user role assignments in managed landing-zone scopes;
- tests that verify production and non-production deployment identities differ;
- inspection of federated credential issuer, subject, and audience restrictions;
- a permissions matrix generated from intended role assignments;
- a pipeline check demonstrating that pull-request jobs cannot apply changes;
- a documented bootstrap and access-recovery exercise; and
- a profile report identifying unavailable PIM or Conditional Access controls in lab deployments.

## References

- [Microsoft: Landing-zone identity and access management](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access-landing-zones)
- [Microsoft: Manage emergency access administrator accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Microsoft: Microsoft Entra licensing](https://learn.microsoft.com/en-us/entra/fundamentals/licensing)
- [Microsoft: Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Microsoft: Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
