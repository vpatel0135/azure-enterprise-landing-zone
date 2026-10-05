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

## Open decisions

| ID | Decision | Working recommendation | Status |
|---|---|---|---|
| D001 | Infrastructure-as-code tool | Terraform as the authoritative implementation | Proposed ([ADR-0001](decisions/0001-use-terraform.md)) |
| D002 | Deployment scope | Make the multi-subscription enterprise profile authoritative and provide an explicitly limited single-subscription lab profile | Proposed ([ADR-0002](decisions/0002-resource-organization.md)) |
| D003 | Management-group hierarchy | Archetype-aligned hierarchy based on the Azure landing-zone reference architecture | Proposed ([ADR-0002](decisions/0002-resource-organization.md)) |
| D004 | Subscription strategy | Separate platform and application environments in the target state; provide an explicitly limited single-subscription lab profile | Proposed ([ADR-0002](decisions/0002-resource-organization.md)) |
| D005 | Identity model | Microsoft Entra ID groups for humans, federated workload identities for automation, managed identities for Azure resources, and monitored emergency access | Proposed ([ADR-0003](decisions/0003-identity-and-access.md)) |
| D006 | Connectivity model | Cost-conscious hub-and-spoke design with expensive components optional | Open |
| D007 | Policy baseline | Layered initiatives composed primarily from built-ins, staged from audit to enforcement, with time-bound exemptions | Proposed ([ADR-0004](decisions/0004-policy-governance.md)) |
| D008 | Monitoring and security | Central workspace design with configurable retention and optional Sentinel | Open |
| D009 | First workload | Choose either the wedding or honeymoon website after inspecting both | Open |

## Current boundary

This brief deliberately does not select detailed Azure services yet. The next decision is the infrastructure-as-code model, because it shapes repository layout, state management, testing, and the deployment workflow.
