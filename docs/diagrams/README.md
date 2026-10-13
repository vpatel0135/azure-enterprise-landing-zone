# Diagrams

The primary end-to-end architecture diagram is maintained as Mermaid source in the [repository README](../../README.md#architecture), so it renders directly on the GitHub project landing page.

The diagram distinguishes between:

- the enterprise target management-group and subscription model;
- the cost-conscious single-subscription lab profile actually deployed;
- passwordless GitHub Actions authentication through OIDC;
- separate plan, non-production apply, and production apply identities;
- workload-specific Terraform state and resource-group RBAC boundaries; and
- the deployed SIT and production Azure Static Web Apps with centralized observability.

Future detailed identity-flow, network, and deployment-flow diagrams should be added here while the README retains the concise recruiter-facing overview.
