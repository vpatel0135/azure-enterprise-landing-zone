# Architecture Decision Review Workbook

This workbook is the approval checkpoint before Terraform implementation begins. Each row summarizes a full architecture decision record (ADR); the ADR remains the authoritative explanation.

## How to review

For each decision, choose one outcome:

- **Accept** — use the proposed decision for implementation.
- **Revise** — record the requested change before implementation.
- **Defer** — leave the affected implementation out of the first release and record what would resolve it.

Accepting a decision does not make it permanent. A later ADR can supersede it, but changes become more expensive once Azure resources and public interfaces depend on it.

## Decision summary

| Order | Decision | Recommendation | Primary cost impact | Cost to reverse later |
|---:|---|---|---|---|
| 1 | [IaC tool](decisions/0001-use-terraform.md) | Terraform only | Remote-state storage and maintenance effort | High after modules and pipelines exist |
| 2 | [Resource organization](decisions/0002-resource-organization.md) | Archetype management groups; separate enterprise subscriptions; constrained lab profile | More subscriptions do not inherently add resource cost, but platform services do | High after policy/RBAC inheritance is established |
| 3 | [Identity and access](decisions/0003-identity-and-access.md) | Group-based access, OIDC, managed identities, PIM where licensed | PIM and Conditional Access licensing for full target | High after identities and federated subjects are deployed |
| 4 | [Policy governance](decisions/0004-policy-governance.md) | Built-ins first; initiatives; audit before enforcement; expiring exemptions | Diagnostics/remediation can add usage cost | Medium; policy can be promoted incrementally |
| 5 | [Network connectivity](decisions/0005-network-connectivity.md) | Regional hub-and-spoke only for connected workloads; website isolated by default | Firewall, gateways, resolvers, NAT, and DDoS plans are optional cost drivers | High after address allocation and peering |
| 6 | [Security monitoring](decisions/0006-security-monitoring.md) | Central platform workspace with selective collection; paid protections opt-in | Log ingestion/retention, alerts, Sentinel, Defender plans | Medium; data movement and retention changes need care |
| 7 | [Resource standards and cost](decisions/0007-resource-standards-and-cost.md) | Stable service-aware names, governed tags, parameterized region, subscription budgets | Budgets are low/no direct cost; chosen regions and SKUs affect spend | High for resource names and primary region |
| 8 | [Repository, state, and delivery](decisions/0008-repository-state-and-delivery.md) | Monorepo, isolated states, separate plan/apply identities, protected applies | CI minutes and test resources; state storage is small | High after state and workflows are active |

## Approval questions

### 1. Infrastructure as code

**Question:** Should Terraform be the only authoritative implementation, with no parallel Bicep version?

**Recommended answer:** Accept.

Why: one complete and tested implementation is a stronger portfolio artifact than two shallower implementations. Terraform also demonstrates skills transferable beyond Azure.

### 2. Enterprise target versus personal lab

**Question:** Should the repository present a multi-subscription enterprise target while offering a clearly weaker single-subscription lab profile?

**Recommended answer:** Accept.

Why: changing the target architecture to fit a personal account would misrepresent enterprise isolation. The lab profile keeps evaluation practical without claiming equivalence.

### 3. Identity licensing

**Question:** Should the enterprise target include PIM and Conditional Access while the lab reports those controls as unavailable when the required licenses are absent?

**Recommended answer:** Accept.

Why: it distinguishes the correct enterprise control from the affordable demonstration path without silently weakening the target.

### 4. Policy rollout

**Question:** Should new policies begin in audit mode and graduate selectively to deny, modify, or deployment effects after their impact is measured?

**Recommended answer:** Accept.

Why: immediate enforcement looks strict but can block valid deployments and conceal poor policy design.

### 5. Network topology

**Question:** Should the enterprise pattern use a traditional regional hub-and-spoke for connected workloads while leaving the public website disconnected unless it needs private services?

**Recommended answer:** Accept.

Why: it demonstrates an enterprise connectivity path without making an inexpensive public workload depend on always-on network appliances.

### 6. Security products and logging

**Question:** Should Microsoft Sentinel, paid Defender plans, long retention, and verbose diagnostics be explicit opt-ins rather than default lab deployments?

**Recommended answer:** Accept.

Why: security tooling must have defined detections, ownership, and budgets. Enabling paid products without an operating process adds expense rather than demonstrated capability.

### 7. Region and standards

**Question:** Should `eastus2` be the example region while remaining a configurable input, with a second region deferred until recovery objectives exist?

**Recommended answer:** Accept unless the intended Azure subscription has quota or service-availability constraints in that region.

Why: a single tested region is more credible than an untested multi-region diagram. Names and region placement become expensive to change later.

### 8. Repository and delivery

**Question:** Should platform and website code live in this monorepo but use separate state files and deployment identities?

**Recommended answer:** Accept.

Why: the portfolio remains understandable end to end while Azure access and failure boundaries stay appropriately separated.

## Recommended approval package

Accept ADRs 0001–0008 together as the version-one architecture, with these qualifications:

1. Paid services remain disabled unless their named profile is selected.
2. No production apply occurs before protected GitHub environments and OIDC identities exist.
3. The single-subscription lab is never described as equivalent to the enterprise target.
4. Website hosting remains a separate decision after the two candidate repositories are inspected.
5. Azure tenant, subscription, quota, and licensing preflight can revise implementation details without silently changing the accepted principles.

## Decisions after approval

The following choices are intentionally deferred until the platform direction is accepted:

- exact Azure Verified Modules and provider versions;
- exact built-in Azure Policy IDs and parameters;
- Azure account/subscription topology available to the maintainer;
- bootstrap identity and state-storage configuration;
- website selection and hosting service;
- domain, DNS, and public edge configuration;
- production recovery objectives and any secondary region; and
- optional paid profile selections.

## Approval record

When approved, update each ADR from **Proposed** to **Accepted**, update the project brief and decision index in the same commit, and record any qualifications here. Do not infer approval from silence or from implementation progress.
