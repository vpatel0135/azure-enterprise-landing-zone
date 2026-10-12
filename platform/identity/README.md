# Platform identity and Azure RBAC

This privileged Terraform root creates the Microsoft Entra security groups and Azure role assignments used by the platform lab. Its state is isolated from organization, management, connectivity, and workload state because it contains tenant identity and authorization metadata.

## Lab assignments

| Group | Role | Scope | Reason |
|---|---|---|---|
| `sg-alz-platform-readers` | Reader | `alz-example` management group | Inherited read visibility for governance and audit. |
| `sg-alz-platform-operators` | Contributor | Lab subscription | Resource management without permission to grant access. |
| `sg-alz-policy-admins` | Resource Policy Contributor | `alz-example` management group | Policy lifecycle without general resource ownership. |
| `sg-alz-access-admins` | None by default | None | Reserved access boundary; privileged access requires a separately reviewed elevation. |

The lab uses a standing policy assignment because the free tenant does not include PIM. The access-administrator group deliberately has no standing Azure role: granting RBAC administration at management-group scope is a separate privileged action. An enterprise deployment should make privileged policy and access groups eligible through PIM instead.

The repository does not create runtime managed identities until a workload needs Azure data-plane access, and it does not create GitHub OIDC identities until the repository environments and exact federated subjects are configured.

## Deployment

1. Deploy the `identity` state container from `bootstrap/terraform-state`.
2. Copy the example backend and variable files to their ignored local equivalents.
3. Put only privately supplied object IDs in `terraform.tfvars`.
4. Initialize, plan, and apply using an authorized bootstrap administrator.
5. Verify group membership and effective Azure access before removing direct bootstrap assignments.

The security groups use `prevent_destroy`. Removing them requires an explicit reviewed code change so an ordinary refactor cannot silently delete the authorization boundary.
