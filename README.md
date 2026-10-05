# Azure Enterprise Landing Zone Reference Implementation

This project will demonstrate how to design, deploy, and operate a production-minded Azure landing zone for a fictional medium-sized organization. The platform will be intentionally cost-conscious so that it can be evaluated and, where practical, deployed from a personal Azure account.

After the platform foundation is validated, an existing personal website will be onboarded as the first governed workload. This proves that the landing zone is usable, rather than only presenting a theoretical architecture.

## Project status

The project is currently in the requirements and architecture-decision phase. No Azure resources are deployed yet.

## Planned outcomes

- A documented enterprise scenario and set of architectural assumptions
- Management-group and subscription organization
- Identity and privileged-access design
- Policy-driven governance and security guardrails
- A cost-conscious connectivity model
- Central monitoring, security, and audit design
- Repeatable infrastructure-as-code deployment
- Automated validation and safe cleanup guidance
- Architecture diagrams and decision records
- Onboarding of one existing website into production and non-production environments

## Guiding principles

- Use production patterns while keeping expensive services optional.
- Prefer enforceable controls and automated tests over screenshots.
- Record important tradeoffs in architecture decision records.
- Keep credentials, tenant identifiers, subscription identifiers, and personal information out of source control.
- Make deployment and teardown safe, documented, and repeatable.

See [the project brief](docs/project-brief.md) for the initial scenario and constraints, the [decision review workbook](docs/decision-review.md) for the choices that need approval, and the [architecture decision index](docs/decisions/README.md) for full records.
