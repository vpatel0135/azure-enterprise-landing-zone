# Platform identity deployment evidence

## Outcome

The lab identity root was deployed on 2026-10-11 using a dedicated remote Terraform state. The post-deployment plan reported no changes.

Four Microsoft Entra security groups exist:

- `sg-alz-platform-readers`
- `sg-alz-platform-operators`
- `sg-alz-policy-admins`
- `sg-alz-access-admins`

Azure RBAC was verified from the live control plane:

| Group | Azure role | Scope |
|---|---|---|
| `sg-alz-platform-readers` | Reader | `alz-example` management group |
| `sg-alz-platform-operators` | Contributor | Lab subscription |
| `sg-alz-policy-admins` | Resource Policy Contributor | `alz-example` management group |
| `sg-alz-access-admins` | None | None |

## Security and cost notes

- Every managed assignment targets a group, not an individual user.
- The access-admin group intentionally has no standing role. A proposed management-group RBAC Administrator assignment was rejected as unnecessarily broad for the lab.
- The lab subscription Owner assignment and tenant-root management-group bootstrap access remain outside this state. They are retained to prevent lockout and must be reviewed separately before removal.
- No application registration, client secret, managed identity, PIM license, or paid Azure resource was created.
- Personal tenant, subscription, user, group, and role-assignment identifiers remain only in ignored local configuration and protected Terraform state.

## Validation performed

- Terraform configuration validation succeeded.
- The identity Terraform test passed.
- TFLint completed without findings.
- Live Microsoft Entra group inventory matched the four intended groups.
- Live Azure RBAC inventory matched the three intended assignments.
- A refresh-only comparison produced a zero-change Terraform plan after canonical role-ID normalization.
