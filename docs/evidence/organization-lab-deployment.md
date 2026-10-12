# Organization lab deployment evidence

- **Validation date:** 2026-10-11
- **Profile:** `lab`
- **Result:** Passed

## Deployed scope

- Created the ten-management-group archetype hierarchy beneath the tenant root.
- Placed the single lab subscription directly beneath `alz-example`.
- Stored organization state in the dedicated `organization` container and `organization.tfstate` key.
- Kept policy assignments, platform resources, and paid networking services outside this deployment.

## Validation results

- Initial reviewed plan: 11 additions, 0 changes, 0 destructions.
- Apply result: 11 additions, 0 changes, 0 destructions.
- Post-deployment plan: no changes.
- `alz-example` reported the expected five direct children.
- Terraform mock tests passed for the lab hierarchy and enterprise production/nonproduction subscription separation.
- Temporary tenant-root User Access Administrator elevation was removed after deployment.
- Management Group Contributor remains for management-group lifecycle operations.

## Lab limitation

The lab subscription represents platform, connectivity, production, and nonproduction responsibilities in one billing and authorization boundary. Resource groups will separate those concerns operationally, but this deployment does not claim the subscription-level isolation of the enterprise profile.

Tenant IDs, subscription IDs, principal IDs, role-assignment IDs, state contents, and plan files are intentionally excluded from this evidence.
