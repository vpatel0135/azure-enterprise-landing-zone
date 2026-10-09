# ADR-0007: Standardize Resource Identity, Placement, and Cost Ownership

- **Status:** Accepted
- **Date:** 2026-10-09
- **Decision owner:** Repository maintainer

## Context

Names, tags, regions, and budgets are inputs to automation and governance, not cosmetic cleanup. Azure services have different naming constraints, many names are difficult or impossible to change, tag support is inconsistent, and budget alerts do not prevent spending. The public repository must also avoid embedding personal or confidential information in globally visible resource names and tags.

The fictional organization begins in one primary region. The design must remain parameterized so another evaluator can deploy where services, quotas, compliance, latency, and price make sense for them.

## Decision drivers

- Make resource purpose understandable without encoding sensitive details.
- Keep names stable when owners or mutable business metadata change.
- Respect service-specific length, character, case, and uniqueness rules.
- Enable consistent ownership, cost, automation, and governance reporting.
- Avoid treating tags as a security or authorization boundary.
- Use one region first while retaining a deliberate multi-region path.
- Make cost ownership and optional paid capabilities visible before deployment.
- Prevent public examples from revealing personal tenant or contact information.

## Decision

Adopt a service-aware naming module, a small governed tag contract, explicit allowed-region configuration, and subscription-level budget ownership.

### Naming contract

The compact human-readable default pattern is:

```text
<resource-type>-<region><environment>-<workload-code>-<instance>
```

Examples:

```text
rg-eus2p-wed-01
asp-eus2p-wed-01
rg-eus2n-hny-01
law-eus2p-mgmt-01
vnet-eus2p-conn-01
```

Components are included only when they provide stable, useful distinction. Not every Azure resource uses every component.

| Component | Example | Rule |
|---|---|---|
| Resource type | `rg`, `asp`, `law`, `vnet` | Use an unambiguous documented Azure abbreviation |
| Region | `eus2` | Use a repository-owned code mapped directly to an Azure region |
| Environment | `p`, `n`, `d`, `t`, `s`, `x` | Append one controlled lifecycle code to the region code |
| Workload code | `wed`, `hny`, `mgmt`, `conn` | Use a centrally registered, short, stable application or platform-capability code |
| Instance | `01` | Use a two-digit sequence maintained independently per resource type |

For services that prohibit hyphens or require lowercase alphanumeric characters, the naming module removes separators while preserving the component order, for example `steus2pwed01`. When Azure reports a global-name collision, the deployer increments that resource type's instance number and replans, such as `steus2pwed02`. Terraform does not probe and increment names automatically because availability can change between plan and apply.

Team ownership is not encoded in the name because teams change. It is recorded in the `owner-group` tag and RBAC configuration. The repository maintains controlled registries for region, environment, workload, and resource-type codes.

Names must not contain:

- personal names or email addresses;
- tenant or subscription IDs;
- confidential project codenames;
- data classification details that reveal sensitive content;
- credentials, tokens, or account numbers; or
- a person's current ownership when ownership can change.

### Scope naming

| Scope | Proposed format/example |
|---|---|
| Management-group ID | Stable lowercase identifier such as `alz-example-platform` |
| Management-group display name | Friendly label such as `Platform` |
| Subscription display name | Function/workload and environment, such as `Website Production` |
| Resource group | `rg-<region><environment>-<workload-code>-<instance>` |
| Terraform state key | Layer and environment, not subscription display name |

Automation uses stable IDs rather than display names where Azure provides both.

## Tag contract

Use lowercase tag keys and controlled lowercase values where practical. Tags supplement names and hierarchy; they do not replace management groups, subscriptions, resource groups, RBAC, policy, or inventory.

### Required workload metadata

| Tag key | Example | Purpose |
|---|---|---|
| `application` | `wedding-site` | Workload grouping |
| `environment` | `prod` | Lifecycle context |
| `owner-group` | `sg-wedding-prod-operators` | Accountable group, not a person's contact data |
| `cost-center` | `portfolio-demo` | Cost allocation category |
| `managed-by` | `terraform` | Expected change path |
| `criticality` | `low`, `medium`, `high`, `mission-critical` | Operational prioritization |
| `data-classification` | `public`, `internal`, `confidential`, `restricted` | Governance input without describing the data |

Platform resources use the same keys where meaningful, with `application` replaced by or normalized to an agreed platform capability value.

### Tag rules

- Do not place secrets, personal contact information, or sensitive business detail in tags.
- Validate keys and allowed values before deployment.
- Apply ownership and cost metadata at the resource-group level and use Policy to inherit or enforce only where the resource supports tags and inheritance is semantically correct.
- Do not overwrite an explicitly valid resource-level value with a resource-group value.
- Do not require unsupported resource types to carry tags.
- Avoid frequently changing values such as deployment timestamps or transient ticket state.
- Treat tag changes as governed metadata changes because they can affect automation and cost reporting.

## Region strategy

Use `eastus2` as the example primary region for the reference configuration, but expose the primary region and allowed-region list as inputs. This is a demonstration default, not a universal recommendation.

Before production deployment, region selection must evaluate:

- required service and SKU availability;
- availability-zone support for the selected service;
- data residency or sovereignty requirements;
- user latency and network connectivity;
- quota and capacity availability;
- pricing and data-transfer implications;
- disaster-recovery objectives; and
- compatibility with paired or chosen recovery regions.

The initial platform is single-region because the fictional requirements have not established a recovery-time or recovery-point objective requiring a second region. The website architecture may use a globally distributed managed service without converting every platform component into a multi-region deployment.

A secondary region is selected from workload recovery requirements, not automatically because Azure documents a regional pair. Any multi-region expansion requires failover, data replication, DNS/traffic routing, monitoring, and recovery testing.

## Cost ownership

### Budgets

- Create a budget at each managed subscription when billing-scope permissions allow it.
- Set separate thresholds for forecast and actual cost.
- Route alerts to role-based destinations supplied outside the public repository.
- Give every subscription and optional paid profile a cost owner.
- Document that Azure budgets notify; they do not automatically stop resources or guarantee a spending cap.

The public module accepts budget amounts as inputs and provides safe example values, but no example value is represented as a universal expected monthly bill.

### Cost inventory

Every deployment profile produces an inventory that classifies resources as:

- no direct resource charge but potentially usage-dependent;
- consumption-based;
- fixed or minimum recurring charge;
- optional paid security/operations capability; or
- likely data-transfer or ingestion cost driver.

The inventory highlights Azure Firewall, gateways, NAT Gateway, DNS Private Resolver, DDoS Network Protection, Log Analytics ingestion/retention, Microsoft Sentinel, paid Defender plans, public edge/WAF services, and workload hosting SKUs when selected.

### Cost controls

- Default the lab profile to the smallest supported footprint that still exercises the design honestly.
- Keep expensive enterprise extensions disabled unless explicitly selected.
- Require tags and subscription boundaries for allocation, while recognizing that not every charge inherits resource tags cleanly.
- Review actual cost after deployment and compare it with the estimate.
- Detect orphaned resources, unattached disks/IPs, unused gateways, excessive log ingestion, and forgotten non-production environments.
- Use scheduled shutdown only for resource types and environments where interruption is acceptable.
- Never implement an automatic destructive shutdown from a budget alert without a separate risk decision.

## Options considered

### Put all metadata in resource names

Rejected. Names have service-specific limits and many cannot change when business metadata changes.

### Use tags without a controlled vocabulary

Rejected. Differences in spelling and casing fragment cost and inventory reports.

### Put personal email addresses in owner tags

Rejected for the public project and as the default enterprise pattern. Group identifiers are more stable and reveal less personal information.

### Hard-code one Azure region

Rejected. Service availability, regulation, quota, latency, and pricing vary by user and workload.

### Deploy two regions to appear enterprise-ready

Rejected without recovery objectives and tests. Duplicate resources do not prove recoverability.

### Automatically stop resources when a budget threshold fires

Rejected. Budget alerts can be delayed, and indiscriminate shutdown can cause a larger business or recovery incident.

## Consequences

- A naming module must account for per-service constraints and deterministic uniqueness.
- Some resources cannot support every tag and require documented exceptions.
- The example is approachable in East US 2 while remaining deployable elsewhere after validation.
- Cost control becomes an ongoing operational responsibility, not a one-time estimate.
- Recovery-region design remains open until workload requirements justify it.

## Implementation guardrails

- Validate all names before resource creation.
- Keep the region short-code map in one version-controlled file.
- Fail enterprise-profile validation for unknown environment, criticality, or data-classification values.
- Do not output personal contact details in plans or inventories.
- Do not treat tags as inherited automatically; implement and test the intended Policy behavior.
- Do not create a paid capability merely because its input block is present; require an explicit enable flag.
- Keep budget notification endpoints outside committed source.
- Generate name, tag, region, and cost inventories during CI validation.

## Validation criteria

This decision will be validated by:

- unit tests covering representative Azure naming constraints;
- deterministic-name tests across repeated plans;
- tests for required tag keys, values, and inheritance behavior;
- negative tests for sensitive-looking example data and raw tenant/subscription IDs;
- allowed-region policy tests;
- a service/SKU availability preflight for the selected region;
- budget and alert configuration inspection; and
- estimated-versus-actual cost reporting after a controlled deployment.

## References

- [Microsoft: Resource organization design area](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org)
- [Microsoft: Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Microsoft: Define your tagging strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Microsoft: Organize Azure resources effectively](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources)
