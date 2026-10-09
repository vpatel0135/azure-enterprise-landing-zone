# Architecture Decision Index

Architecture decision records (ADRs) capture consequential choices, alternatives, and validation criteria. A proposal is not an approved implementation decision.

## Status meanings

| Status | Meaning |
|---|---|
| Proposed | Ready for discussion; implementation must not rely on it as final |
| Accepted | Approved as the current design direction |
| Superseded | Replaced by a newer ADR, which must be linked |
| Rejected | Considered and intentionally not selected |

## Decisions

| ADR | Topic | Status | Working selection |
|---|---|---|---|
| [ADR-0001](0001-use-terraform.md) | Infrastructure-as-code tool | Accepted | Terraform |
| [ADR-0002](0002-resource-organization.md) | Management groups, subscriptions, and deployment profiles | Accepted | Archetype hierarchy with shared web-portfolio prod/nonprod subscriptions and a constrained lab profile |
| [ADR-0003](0003-identity-and-access.md) | Human, automation, workload, and emergency identities | Accepted | Group-based access, OIDC, managed identities, optional PIM, and documented emergency access |
| [ADR-0004](0004-policy-governance.md) | Azure Policy governance and exceptions | Accepted | Layered initiatives, built-ins first, audit-to-enforce rollout, and expiring exemptions |
| [ADR-0005](0005-network-connectivity.md) | Network topology, DNS, ingress, and egress | Accepted | Low-cost regional hub and demo spoke with paid services optional and Online workloads isolated by default |
| [ADR-0006](0006-security-monitoring.md) | Security posture, centralized logging, alerting, and SIEM | Accepted | Central platform monitoring, workload-owned Application Insights, and opt-in paid protections |
| [ADR-0007](0007-resource-standards-and-cost.md) | Naming, tagging, regional placement, and cost ownership | Accepted | Compact service-aware names, governed tags, East US 2 default, and subscription budgets |
| [ADR-0008](0008-repository-state-and-delivery.md) | Repository structure, Terraform state, testing, and delivery | Accepted | Platform monorepo, separate application repos, isolated state, OIDC identities, and protected applies |

## Review checklist

Before changing an ADR to **Accepted**, confirm that:

- the problem and constraints match the intended portfolio scenario;
- the selected option is affordable to demonstrate or is clearly optional;
- rejected alternatives are represented fairly;
- security and operational consequences are explicit;
- the enterprise target is not weakened to fit the lab profile;
- validation evidence can be produced during implementation; and
- the choice does not publish personal tenant details or credentials.

## Review status

The repository owner completed the guided review and explicitly accepted ADRs 0001–0008 on 2026-10-09. Implementation can now rely on these decisions. Website hosting remains a separate workload-onboarding decision.

## Change process

When a proposed decision is approved, change its ADR status and the matching row in `docs/project-brief.md` to **Accepted** in the same pull request. If a later choice reverses it, add a new ADR and mark the original **Superseded** rather than rewriting its history.
