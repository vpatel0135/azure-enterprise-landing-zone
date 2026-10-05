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
| [ADR-0001](0001-use-terraform.md) | Infrastructure-as-code tool | Proposed | Terraform |
| [ADR-0002](0002-resource-organization.md) | Management groups, subscriptions, and deployment profiles | Proposed | Archetype-aligned hierarchy with an enterprise target and constrained lab profile |
| [ADR-0003](0003-identity-and-access.md) | Human, automation, workload, and emergency identities | Proposed | Group-based access, OIDC, managed identities, PIM where licensed, and emergency accounts |
| [ADR-0004](0004-policy-governance.md) | Azure Policy governance and exceptions | Proposed | Layered initiatives, built-ins first, audit-to-enforce rollout, and expiring exemptions |
| [ADR-0005](0005-network-connectivity.md) | Network topology, DNS, ingress, and egress | Proposed | Regional hub-and-spoke for connected workloads with optional paid services and isolated Online workloads |

## Review checklist

Before changing an ADR to **Accepted**, confirm that:

- the problem and constraints match the intended portfolio scenario;
- the selected option is affordable to demonstrate or is clearly optional;
- rejected alternatives are represented fairly;
- security and operational consequences are explicit;
- the enterprise target is not weakened to fit the lab profile;
- validation evidence can be produced during implementation; and
- the choice does not publish personal tenant details or credentials.

## Pending review

The following choices require repository-owner confirmation before implementation begins:

1. Use Terraform rather than Bicep as the authoritative IaC language.
2. Use the proposed archetype-aligned management-group hierarchy.
3. Treat the multi-subscription model as authoritative and the single-subscription model only as a lab convenience.
4. Use the proposed identity separation and accept that PIM and Conditional Access depend on licensing.
5. Use the proposed policy lifecycle and exemption process.
6. Use traditional hub-and-spoke as the default connected topology while keeping the public website disconnected from the hub unless it gains private dependencies.

## Change process

When a proposed decision is approved, change its ADR status and the matching row in `docs/project-brief.md` to **Accepted** in the same pull request. If a later choice reverses it, add a new ADR and mark the original **Superseded** rather than rewriting its history.
