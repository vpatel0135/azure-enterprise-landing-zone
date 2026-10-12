# Policy audit baseline deployment evidence

- **Validation date:** 2026-10-11
- **Assignment scope:** `alz-example`
- **Result:** Passed

## Deployed controls

- Microsoft built-in `Allowed locations` definition, observed at version `1.1.0`.
- Custom reusable definition that audits a required tag supplied as a parameter.
- Organizational initiative containing the allowed-location control and seven required-tag references.
- Management-group assignment with `eastus2` as the allowed location.
- Audit effects for both location and tag controls.

## Safety and cost

- Reviewed plan: 3 additions, 0 changes, 0 destructions.
- Apply result: 3 additions, 0 changes, 0 destructions.
- Post-deployment plan: no changes.
- No deny, modify, or deploy-if-not-exists effects were enabled.
- No remediation identity or remediation task was created.
- No paid security or monitoring plan was enabled.
- Temporary tenant-root User Access Administrator elevation was removed after deployment.

## Initial compliance snapshot

Azure Policy reported one assignment and two noncompliant resources in the first asynchronous snapshot. This is discovery evidence, not an enforcement decision. The next review must identify each missing tag or location finding, account for Azure Policy evaluation delay, and resolve false positives before any effect is promoted.

The signed-in bootstrap identity retains Resource Policy Contributor at `alz-example` for policy lifecycle management. An existing Owner assignment at that scope is deferred to the dedicated identity and RBAC implementation so it can be reviewed without mixing access cleanup into the policy deployment.

Tenant IDs, subscription IDs, principal IDs, role-assignment IDs, raw state, and plan files are intentionally excluded.
