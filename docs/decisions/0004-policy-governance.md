# ADR-0004: Govern with Layered Policy Initiatives and Expiring Exemptions

- **Status:** Accepted
- **Date:** 2026-10-09
- **Decision owner:** Repository maintainer

## Context

The landing zone needs enforceable guardrails without turning the reference implementation into a large, opaque collection of policies. Controls must be understandable, testable, and safe to introduce into an existing tenant. They also need different behavior for platform, public-facing, corporate, sandbox, and decommissioned subscriptions.

Azure Policy definitions can audit, deny, modify, or deploy related configuration. Enforcement can disrupt deployments if it is enabled before its impact is understood. Policies with `modify` or `deployIfNotExists` also use a managed identity with permissions to change resources, so their remediation access is part of the security design.

## Decision drivers

- Prefer Microsoft-maintained controls where they satisfy the requirement.
- Keep the policy inventory small enough for a reviewer to understand.
- Assign controls at the highest appropriate archetype scope without overloading the tenant root.
- Detect impact before blocking legitimate deployments.
- Make every exception owned, justified, reviewable, and temporary.
- Separate compliance measurement from automatic remediation.
- Make policy changes reviewable and testable as code.
- Preserve a lighter but still safe sandbox experience.

## Decision

Manage Azure Policy definitions, initiatives, assignments, exemptions, identities, and role assignments through Terraform.

Use **initiatives** as the stable assignment interface, even when an initiative initially contains only one policy. Prefer built-in policy definitions. Add custom definitions only when a documented requirement cannot be met by a suitable built-in or when a stable wrapper is needed to standardize behavior.

### Layered assignment model

| Scope | Initiative purpose | Typical behavior |
|---|---|---|
| `alz-example` | Universal organizational baseline | Required metadata, allowed regions, security auditing |
| `Platform` | Centrally operated service protection | Diagnostic coverage, restricted administrative patterns |
| `Management` | Logging and monitoring integrity | Audit or deny configurations that weaken central observability |
| `Connectivity` | Shared network governance | Network diagnostics and protection of shared routing/DNS resources |
| `Landing Zones` | Workload-independent baseline | Secure transport, diagnostics, identity-first access, cost metadata |
| `Online` | Internet-facing workload controls | Approved ingress patterns, public exposure auditing, edge-service requirements where selected |
| `Corp` | Private and hybrid-connected workload controls | Private connectivity, DNS, routing, and public-endpoint restrictions |
| `Sandboxes` | Safe experimentation | Audit-heavy baseline, budgets, allowed regions, no production data |
| `Decommissioned` | Quarantine | Deny new or changed resources except authorized cleanup operations |

The tenant root receives no project-specific assignment. The `alz-example` parent is the highest scope owned by this reference implementation.

### Initial control catalog

The first release will implement a focused catalog rather than claiming comprehensive regulatory compliance.

| Control | Initial effect | Target steady state | Primary scope |
|---|---|---|---|
| Allowed Azure regions | Audit | Deny | `alz-example` |
| Required ownership and cost tags | Audit | Modify where safe; otherwise deny missing values | `alz-example` or `Landing Zones` |
| Resource diagnostic settings | AuditIfNotExists | DeployIfNotExists for supported resources | `Platform` and `Landing Zones` |
| Secure transfer/TLS requirements | Audit | Deny for supported resource types | `Landing Zones` |
| Public network exposure | Audit | Archetype-specific deny or approved exceptions | `Online` and `Corp` |
| Managed identity availability/use | Audit | Audit or deny based on service capability | `Landing Zones` |
| Defender for Cloud baseline | Audit | Configurable enablement; paid plans are opt-in | Appropriate subscription scopes |
| Decommissioned subscription changes | Deny | Deny | `Decommissioned` |

Exact built-in definition IDs, versions, parameters, supported resource types, and effects will be captured in a machine-readable catalog during implementation. No policy is selected solely because it appears in a generic benchmark.

### Enforcement lifecycle

Every new or materially changed control follows these stages:

1. **Design:** map the requirement to a built-in or justified custom definition and document its scope.
2. **Static validation:** format, parse, lint, and test the definition, initiative membership, parameters, and assignment.
3. **Audit:** deploy with `audit` or `auditIfNotExists` where the definition supports a configurable effect.
4. **Observe:** inspect compliance results and identify false positives, unsupported resource types, and remediation cost.
5. **Remediate:** correct existing resources deliberately. `modify` and `deployIfNotExists` remediation tasks are separately approved.
6. **Enforce:** promote suitable preventive controls to `deny`, `modify`, or `deployIfNotExists` after evidence shows acceptable impact.
7. **Review:** monitor compliance, exemptions, policy version changes, and operational incidents.

Production enforcement changes require a reviewed plan and protected-environment approval. The same initiative is used across stages with controlled parameters where possible; separate copied definitions are avoided.

### Exceptions

Use Azure Policy exemptions for intentional exceptions. Avoid assignment `notScopes` for business exceptions because they provide weaker exception context. A `notScope` is reserved for a structural or technical exclusion that truly should not be evaluated by the assignment.

Each exemption must include:

- a named owner;
- the affected scope;
- the business or technical justification;
- the policy or initiative reference;
- an exemption category such as `Waiver` or `Mitigated`;
- an expiration date;
- compensating controls when applicable; and
- a tracking reference suitable for a public example without exposing private information.

Terraform configuration must reject non-sandbox exemptions without an expiration date. Expired exemptions are not silently renewed.

### Remediation identities

Assignments using `modify` or `deployIfNotExists` receive a dedicated managed identity and only the roles declared by the selected policy definitions. Do not reuse the CI/CD deployment identity as the policy remediation identity. Role assignments are included in review output so the ability of Policy to change resources is visible.

### Built-in policy versions

Record the referenced built-in definition IDs and version metadata in the catalog. Automated checks should report upstream version drift. Updates are reviewed rather than adopted implicitly because built-in behavior and parameters can change.

## Options considered

### Assign many individual policies directly

Rejected. It creates assignment sprawl and makes it harder to reason about the intended control objective. Initiatives provide a stable grouping and parameter interface.

### Copy every built-in into a custom definition

Rejected. Copies lose Microsoft's maintenance path and create an unnecessary update burden. Custom policy is reserved for genuine gaps or deliberate wrappers.

### Enable deny effects immediately

Rejected. A deny-first rollout can break existing resources and delivery workflows before false positives and service limitations are understood.

### Audit-only governance

Rejected as the target state. Audit provides visibility but does not prevent known high-impact misconfiguration. Controls graduate selectively after validation.

### Broad exclusions with `notScopes`

Rejected for ordinary exceptions. Exemptions provide ownership, category, expiration, and compliance visibility.

### Claim a regulatory certification

Rejected. Mapping policies to a standard can support compliance work, but this portfolio implementation does not establish that an organization or workload is certified.

## Consequences

- Policy rollout is slower than enabling a large baseline in deny mode, but its operational impact is measurable.
- The repository must maintain a control catalog and test assignment inheritance.
- Some controls require remediation identities and role assignments.
- Compliance state can lag after deployment because Azure Policy evaluation is asynchronous.
- The lab profile can exercise definitions and assignments but might not prove every management-group inheritance path.
- Paid Defender plans and high-volume diagnostic ingestion remain explicit cost choices.

## Implementation guardrails

- Prefer built-in definitions and record why each control is included.
- Parameterize effects when supported; do not edit built-in definitions.
- Include a clear non-compliance message on assignments.
- Keep definition location and managed-identity location configurable within supported regions.
- Use the minimum roles needed by remediation identities.
- Do not create remediation tasks automatically during pull-request validation.
- Do not use policy to deploy secrets or embed sensitive values.
- Test that `Online` and `Corp` can diverge on public-network controls without duplicating the universal baseline.
- Treat policy deletion and initiative membership removal as potentially breaking changes requiring review.

## Validation criteria

This decision will be validated by:

- schema and static tests for custom policy assets;
- tests for expected initiative membership and assignment scopes;
- a machine-readable inventory of definition IDs, versions, effects, and parameters;
- tests requiring owner, justification, category, and expiration for exemptions;
- a role inventory for each remediation identity;
- plan evidence showing audit parameters before enforcement promotion;
- compliance queries after deployment; and
- negative deployment tests proving selected deny controls work as intended.

## References

- [Microsoft: Azure governance design area](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/governance)
- [Microsoft: Azure Policy overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Microsoft: Built-in policy initiatives](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-initiatives)
- [Microsoft: DeployIfNotExists effect](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effect-deploy-if-not-exists)
- [Microsoft: Remediate noncompliant resources](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/remediate-resources)
