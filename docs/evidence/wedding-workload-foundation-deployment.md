# Wedding workload foundation deployment evidence

## Outcome

The Wedding workload foundation was deployed to the lab subscription on 2026-10-12. Terraform created five objects and a post-deployment refresh reported no changes.

The deployment created:

- production resource group `rg-eus2p-wed-01`;
- non-production resource group `rg-eus2n-wed-01`;
- Microsoft Entra security group `sg-wed-operators`; and
- one resource-group-scoped Contributor assignment for that group in each environment.

Resource groups carry the approved application, environment, owner-group, cost-center, managed-by, criticality, and data-classification tags. No paid hosting resource was created in this step.

## Isolation boundary

The lab profile uses one Azure Free Trial subscription, so its production and non-production environments do not have subscription-level isolation. Separate resource groups, RBAC scopes, and the isolated `wedding.tfstate` key demonstrate the onboarding pattern without misrepresenting the lab as the enterprise target.

The application repository will own application-specific resources inside these platform-created resource groups. Application plan and apply identities remain intentionally deferred until the repository and protected GitHub environment subjects are known. Those identities will be environment-specific and will not receive subscription-wide access.

## Validation performed

- Terraform formatting completed successfully.
- Terraform initialization used the `workload-foundations` state container and `wedding.tfstate` key.
- Terraform validation succeeded.
- The native test verified the two approved resource-group names and group-based access model.
- The reviewed plan contained five additions, no changes, and no deletions.
- The apply created five objects and destroyed none.
- A live post-apply plan reported zero drift.
