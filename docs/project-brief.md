# Project Brief

## Purpose

Build a public, portfolio-quality Azure Enterprise Landing Zone reference implementation and then onboard an existing personal website as its first representative workload.

The repository should demonstrate both implementation ability and architectural judgment. It must explain why major choices were made, what alternatives were considered, and how a larger organization could extend the design.

## Fictional organization

The working scenario is a medium-sized organization beginning a structured Azure adoption program.

Initial assumptions:

- The organization has multiple application teams and a small central platform team.
- It operates customer-facing and internal applications.
- It requires separate production and non-production environments.
- The platform team owns tenant-level governance, identity guardrails, shared connectivity, security, monitoring, and subscription provisioning.
- Application teams deploy and operate resources within governed workload subscriptions.
- The organization expects growth, but the reference implementation must also be practical for a personal Azure account.
- The first workload will be an existing wedding or honeymoon website.

These assumptions are provisional. Changes will be recorded rather than silently incorporated.

## Selected operating model

**Hybrid governance** is the working choice.

The central platform team controls shared foundations and organization-wide guardrails. Application teams retain autonomy inside clearly defined subscription boundaries. This provides a realistic demonstration of enterprise governance without implying that every application resource is centrally managed.

## Success criteria

The landing zone is successful when:

1. A new environment can be created from version-controlled infrastructure as code.
2. Resources are placed beneath a documented management-group and subscription hierarchy.
3. Guardrails are assigned through policy and validated automatically.
4. Administrative access follows least-privilege and separation-of-duties principles.
5. Network, DNS, logging, monitoring, security, and cost-management responsibilities are explicit.
6. Expensive enterprise services are optional and their production tradeoffs are documented.
7. No secrets or personal Azure identifiers are stored in the public repository.
8. The implementation has tests, deployment guidance, and cleanup instructions.
9. A website can be deployed into non-production and production through a governed delivery process.
10. Documentation and diagrams allow a reviewer to understand the system without deploying it.

## Constraints

- Public GitHub repository
- Personal-project budget
- No dependency on private company systems
- No committed secrets or personally identifying cloud configuration
- Reusable configuration rather than hard-coded tenant details
- Safe resource teardown must be considered from the beginning

## Decision sequence

Major decisions will be made in this order because later choices depend on earlier ones:

1. Scenario, requirements, and operating model
2. Infrastructure-as-code tool and repository strategy
3. Tenant assumptions, management groups, and subscription model
4. Identity, privileged access, and emergency access
5. Governance, policy, naming, tagging, and allowed regions
6. Network topology, DNS, ingress, egress, and hybrid-connectivity assumptions
7. Security, secrets, logging, monitoring, and retention
8. Platform automation, CI/CD, testing, and deployment identities
9. Cost controls and optional enterprise capabilities
10. Workload onboarding model
11. Website hosting architecture and deployment

## Decision register

| ID | Decision | Working recommendation | Status |
|---|---|---|---|
| D001 | Infrastructure-as-code tool | Terraform as the authoritative implementation | Accepted ([ADR-0001](decisions/0001-use-terraform.md)) |
| D002 | Deployment scope | Multi-subscription enterprise target with an explicitly limited single-subscription lab profile | Accepted ([ADR-0002](decisions/0002-resource-organization.md)) |
| D003 | Management-group hierarchy | Archetype-aligned hierarchy based on the Azure landing-zone reference architecture | Accepted ([ADR-0002](decisions/0002-resource-organization.md)) |
| D004 | Subscription strategy | Shared web-portfolio production and non-production subscriptions, with graduation criteria for dedicated workload subscriptions | Accepted ([ADR-0002](decisions/0002-resource-organization.md)) |
| D005 | Identity model | Entra groups for humans, separate OIDC plan/apply identities, system-assigned runtime identity by default, optional PIM, and documented emergency access | Accepted ([ADR-0003](decisions/0003-identity-and-access.md)) |
| D006 | Connectivity model | Low-cost regional hub and demo spoke; Online workloads disconnected unless required; paid transit and inspection optional | Accepted ([ADR-0005](decisions/0005-network-connectivity.md)) |
| D007 | Policy baseline | Layered initiatives composed primarily from built-ins, staged from audit to enforcement, with time-bound exemptions | Accepted ([ADR-0004](decisions/0004-policy-governance.md)) |
| D008 | Monitoring and security | Central platform workspace, workload-owned Application Insights, selective collection, and opt-in paid security plans | Accepted ([ADR-0006](decisions/0006-security-monitoring.md)) |
| D009 | First workload | Choose either the wedding or honeymoon website after inspecting both | Open |
| D010 | Naming, tagging, region, and cost | Compact `<type>-<region><env>-<workload>-<nn>` names; governed metadata; East US 2 default; subscription budgets | Accepted ([ADR-0007](decisions/0007-resource-standards-and-cost.md)) |
| D011 | Repository, state, and delivery | Platform monorepo, separate application repos, isolated state, OIDC plan/apply identities, PR validation, and protected applies | Accepted ([ADR-0008](decisions/0008-repository-state-and-delivery.md)) |

## Current boundary

The platform direction is accepted. The next implementation phase establishes the repository foundation and remote-state bootstrap before deploying the organization, management, connectivity, and workload-foundation layers. Website hosting remains open until the candidate application repositories are inspected.
