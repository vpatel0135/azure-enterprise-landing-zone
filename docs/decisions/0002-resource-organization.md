# ADR-0002: Organize the Platform by Archetype and Subscription Boundary

- **Status:** Proposed
- **Date:** 2026-10-05
- **Decision owner:** Repository maintainer

## Context

The landing zone needs to demonstrate an enterprise resource hierarchy while remaining possible to evaluate with a personal Azure account. A production target should not be distorted merely because the repository owner might initially have only one subscription.

Management groups should express durable governance archetypes, not mirror a company organization chart or software-development environments. Subscription placement determines inherited Azure Policy and role assignments, so hierarchy design is a security and operating-model decision.

The first workload is a public website. It belongs to the **Online** archetype because it is internet-facing and does not require traditional IP connectivity to a corporate network.

## Decision drivers

- Follow the Azure landing-zone design principles of policy-driven governance and subscription democratization.
- Keep platform responsibilities separate from workload ownership.
- Isolate production from non-production at a meaningful authorization, policy, quota, and cost boundary.
- Avoid management groups that exist only to distinguish development from production.
- Show an enterprise target state without requiring a personal user to purchase or create several subscriptions just to inspect the project.
- Allow future internal or hybrid-connected workloads without redesigning the hierarchy.

## Enterprise target state

```text
Tenant Root Group
└── alz-example
    ├── Platform
    │   ├── Management
    │   │   └── sub-platform-management
    │   ├── Connectivity
    │   │   └── sub-platform-connectivity
    │   └── Identity
    │       └── (subscription only when legacy identity services are required)
    ├── Landing Zones
    │   ├── Online
    │   │   ├── sub-website-nonprod
    │   │   └── sub-website-prod
    │   └── Corp
    │       └── (future internal or hybrid-connected workloads)
    ├── Sandboxes
    │   └── (temporary experimentation subscriptions)
    └── Decommissioned
        └── (quarantined subscriptions awaiting removal)
```

The top-level `alz-example` management group provides a safe boundary for the reference implementation. Only minimal, universally applicable controls belong at this scope. Tenant-root assignments are avoided unless a control genuinely must affect every subscription in the tenant.

### Management-group responsibilities

| Management group | Purpose | Example inherited controls |
|---|---|---|
| `alz-example` | Boundary for the reference implementation | Required metadata, baseline audit controls, permitted regions |
| `Platform` | Parent for centrally operated services | Platform-team access and stricter change controls |
| `Management` | Monitoring, operational data, and automation | Diagnostic settings and protected logging resources |
| `Connectivity` | Shared networking and DNS | Network operator access and network-specific policies |
| `Identity` | Optional legacy directory infrastructure | Hardened compute and restricted administration |
| `Landing Zones` | Workload-independent application guardrails | Security baseline and workload-owner boundaries |
| `Online` | Public or internet-facing workloads | Public-endpoint and edge-security controls |
| `Corp` | Internal or hybrid-connected workloads | Private networking, DNS, and routing requirements |
| `Sandboxes` | Time-bound experimentation | Budget limits and a deliberately lighter policy set |
| `Decommissioned` | Quarantine before deletion | Deny deployments and remove ordinary workload access |

## Subscription decisions

### Platform subscriptions

- **Management:** owns central Log Analytics, monitoring, automation, and related operational services.
- **Connectivity:** owns shared hub networking, DNS, and optional firewall or hybrid gateways.
- **Identity:** is not created by default. Microsoft Entra ID is the identity control plane and does not need an Azure subscription. This subscription exists only if the scenario adds resources such as Active Directory Domain Services domain controllers or Microsoft Entra Domain Services.

### Workload subscriptions

Production and non-production website environments use separate subscriptions in the enterprise target. This isolates access, policy exceptions, quotas, billing, and deployment impact. Both remain under `Online`, because management groups represent workload archetypes rather than lifecycle environments.

A single application landing zone comprises the website's production and non-production subscriptions together; it is not synonymous with one subscription.

## Deployment profiles

The repository will expose profiles without pretending that they provide identical isolation.

### `enterprise`

The authoritative architecture:

- deploys the full management-group hierarchy;
- expects separate Management, Connectivity, website production, and website non-production subscriptions;
- leaves Identity, Sandbox, and future workload subscriptions optional;
- applies policy at management-group scope; and
- keeps independently managed layers in separate Terraform state files.

### `lab`

A reduced-cost evaluation profile:

- uses one existing subscription supplied by the evaluator;
- separates management, connectivity, non-production, and production resources with resource groups and naming;
- does not claim subscription-level isolation;
- omits costly shared network appliances by default;
- exercises module composition, policy, tagging, deployment, and teardown behavior where the available scope permits; and
- documents every control that cannot be demonstrated faithfully in one subscription.

The lab profile is an evaluation convenience, not the enterprise target architecture. Code paths should share modules and configuration contracts so that it does not become a separate toy implementation.

## Options considered

### Environment-based management groups

Rejected. Creating `Production` and `NonProduction` management groups would conflate lifecycle stage with governance archetype and create avoidable policy duplication. Subscription boundaries provide environment isolation while both website environments inherit the same Online baseline.

### Business-unit hierarchy

Rejected for the reference scenario. Organizational structures change frequently and do not necessarily correspond to different policy or connectivity requirements.

### One subscription for everything

Rejected as the enterprise target. Resource groups do not provide the same quota, billing, policy, authorization, or blast-radius boundaries as subscriptions. It remains available only as the explicitly constrained lab profile.

### Separate management group per workload

Rejected by default. A new management group is justified only when a distinct policy archetype is required, such as a regulated workload—not simply because a new application exists.

## Consequences

- The hierarchy remains compact and policy inheritance is understandable.
- The public website has an unambiguous placement under `Online`.
- Production and non-production are isolated without duplicating management-group policy.
- A future private workload can use `Corp` and shared connectivity without reorganizing the estate.
- Enterprise deployment requires access to several subscriptions and management-group permissions.
- The lab profile must clearly report its weaker isolation and cannot be presented as proof of the full target state.

## Guardrails for implementation

- Management-group IDs will be parameterized and globally stable within a tenant.
- Display names may be friendly; automation must use immutable IDs.
- Subscription IDs and tenant IDs must be supplied outside committed source.
- Terraform must validate that production and non-production subscription IDs differ in the `enterprise` profile.
- Platform and application owners receive roles at the lowest practical scope; management groups are not used as a shortcut for broad workload administration.
- Moving subscriptions between archetypes requires review because inherited policy and access can change.

## Validation criteria

This decision will be validated by:

- a test that asserts the expected parent-child management-group relationships;
- a test that prevents identical production and non-production subscription IDs in the enterprise profile;
- a policy-assignment inventory showing inheritance by archetype;
- Terraform plans for both profiles; and
- documentation that identifies controls omitted or weakened in the lab profile.

## References

- [Microsoft: Azure landing-zone design principles](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-principles)
- [Microsoft: Management groups](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups)
- [Microsoft: Manage application development environments](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/management-application-environments)
- [Microsoft: Tailor the Azure landing-zone architecture](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/tailoring-alz)
- [Microsoft: Subscription vending implementation guidance](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/subscription-vending)
