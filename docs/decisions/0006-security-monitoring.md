# ADR-0006: Centralize Platform Visibility and Make Paid Security Explicit

- **Status:** Proposed
- **Date:** 2026-10-05
- **Decision owner:** Repository maintainer

## Context

The platform team needs estate-wide visibility into control-plane activity, governance, service health, and shared services. Workload teams also need application telemetry for troubleshooting and performance. Sending every available log category to one workspace would be simple but can create unnecessary ingestion cost, expose workload data too broadly, and make a future Microsoft Sentinel decision more expensive.

Security posture management, threat protection, SIEM, and operational monitoring overlap but are not interchangeable. The project must show how they work together without claiming that an empty dashboard or a paid product automatically makes the landing zone secure.

## Decision drivers

- Provide a horizontal view of platform health and security-relevant activity.
- Keep workload teams able to access telemetry for resources they operate.
- Avoid collecting verbose data without a query, alert, investigation, or retention requirement.
- Make ingestion, retention, alerting, Defender plans, and Sentinel costs visible.
- Separate platform monitoring from application-specific observability responsibilities.
- Preserve evidence needed for incident investigation and governance review.
- Use policy to find and close diagnostic-coverage gaps.
- Ensure alerts have owners and actionable response procedures.

## Decision

Deploy one central Log Analytics workspace in the Management subscription for the initial single-tenant, single-region scenario. Use it for platform operations and selected security-relevant data.

Do not require all application telemetry to use the central workspace. Workload teams can use workspace-based Application Insights and, when access, retention, data residency, or cost allocation requires it, a workload-owned Log Analytics workspace. Central policy collects only the platform and security signals that the platform team is accountable for.

### Data ownership boundary

| Signal | Default owner | Default destination |
|---|---|---|
| Azure subscription Activity Log | Platform team | Central workspace |
| Management-group policy compliance | Platform team | Azure Policy compliance with central reporting |
| Platform resource logs | Platform team | Central workspace, selected categories |
| Service Health and Resource Health | Platform team | Azure Monitor alerts/action groups |
| Defender for Cloud recommendations and alerts | Security/platform team | Defender for Cloud; integrated destination when enabled |
| Website application traces, requests, and dependencies | Workload team | Workspace-based Application Insights |
| Website deployment audit events | Workload and platform teams | GitHub/Azure activity evidence as appropriate |
| High-volume debug logs | Workload team | Workload destination with short or lower-cost retention as justified |
| Microsoft Entra audit and sign-in logs | Identity/security team | Central security destination when licensing and requirements permit |

### Workspace topology

Start with one central platform workspace because the scenario has one tenant, one primary region, and a small platform team. Add another central workspace only for a documented boundary such as:

- different data residency requirements;
- materially different access-control requirements;
- separate security operations ownership;
- incompatible retention requirements;
- regional availability or collection requirements; or
- proven Sentinel cost separation needs.

Workspace count is not an environment-separation mechanism by itself. Production and non-production access is enforced through Azure RBAC and resource-context access where suitable.

### Collection policy

Every collected table or diagnostic category must have at least one declared purpose:

- an alert or detection;
- a dashboard or service-level indicator;
- an operational troubleshooting query;
- an audit or incident-investigation requirement; or
- a validated dependency of an enabled security product.

Avoid enabling `allLogs` blindly across the estate. Maintain a service-by-service diagnostic catalog containing selected categories, destinations, expected volume, owner, and purpose. Use Azure Policy to audit missing settings first and move supported resources to `deployIfNotExists` only after destination, permissions, and cost behavior are validated.

### Retention

- Make interactive and long-term retention configurable by table or data class.
- Keep the lab profile at the service's economical/default retention unless a test requires otherwise.
- Define longer production retention from an explicit audit, incident-response, or business requirement.
- Use long-term retention or an appropriate archive destination for infrequently queried evidence rather than keeping all data interactive.
- Never describe retention as compliant without tying it to a named requirement.
- Test retrieval, not just storage, for any data claimed as incident evidence.

### Alerts and response

The initial platform alert set covers:

- Azure Service Health events;
- Resource Health changes for shared platform components;
- policy compliance degradation;
- unexpected privileged role or policy changes where the signal is available;
- emergency-access account use when identity logs are connected;
- diagnostic pipeline or data-collection failure;
- abnormal Log Analytics ingestion volume; and
- cost-budget thresholds.

Each alert has severity, owner, notification route, expected response, suppression rule, and test method. An alert without a receiver and response procedure is incomplete. The public repository uses placeholders and test routes; it does not contain personal email addresses or phone numbers.

### Microsoft Defender for Cloud

- Use foundational posture recommendations and secure score as inputs to remediation work, not as proof of security.
- Make every paid Defender plan an explicit per-subscription configuration choice.
- Do not use a blanket “enable all plans” default in the personal lab.
- Document the protected resource types, pricing dimensions, data dependencies, and owner before enabling a plan.
- Review recommendations and exemptions through the same governed workflow as other security findings.

The enterprise profile can define a recommended protection matrix, but an evaluator must opt in to paid plans.

### Microsoft Sentinel

Microsoft Sentinel is an optional `siem` profile, disabled by default. Enable it when the scenario includes a security operations function, defined detections, incident routing, and an accepted ingestion/retention budget.

Before enabling Sentinel on the central workspace, evaluate whether operational data in that workspace should share the Sentinel billing and access boundary. A separate security workspace is justified if cost, access, or ownership requirements outweigh the benefits of a single workspace.

The project must not enable Sentinel merely to display it in an architecture diagram.

### Application observability

The website onboarding must define:

- availability and latency indicators;
- failure and dependency telemetry;
- deployment markers;
- user-data and privacy boundaries;
- sampling and retention;
- alert thresholds and owners; and
- a small dashboard or workbook backed by real queries.

Application logs must not record secrets, authentication tokens, or unnecessary personal data.

## Cost controls

- Use pay-as-you-go ingestion initially; commitment tiers require observed stable volume and an explicit decision.
- Set a budget and ingestion-volume alert for monitoring resources.
- Review table-level ingestion trends after onboarding each data source.
- Use transformations or source filtering only after confirming that discarded fields/events are not required for detections or investigations.
- Consider lower-cost table plans for infrequently queried data that does not drive alerts, subject to feature limitations.
- Treat daily caps as an emergency cost guardrail, not normal capacity management, because they can create visibility gaps.
- Keep Sentinel, paid Defender plans, long retention, data export, and high-frequency log alerts off in the lab unless specifically selected.

## Options considered

### One workspace for every platform and workload log

Rejected as a universal rule. It simplifies search but can create access, cost, ownership, and Sentinel billing problems.

### Separate workspace for every subscription

Rejected as the default. It increases configuration and query complexity without a demonstrated boundary requirement.

### Enable all diagnostic categories

Rejected. Availability of a log category does not establish its operational value, and verbose categories can dominate ingestion cost.

### Enable every Defender plan and Sentinel by default

Rejected. These capabilities can be valuable, but they carry resource-specific and ingestion-related costs and require an operating process.

### Store logs without alerts or runbooks

Rejected. Collection alone does not provide detection or response capability.

## Consequences

- The initial platform has centralized visibility without absorbing every application log.
- A diagnostic catalog becomes a maintained architecture artifact.
- Security capability varies by selected profile and must be reported honestly.
- Some identity and security signals depend on licensing and connector availability.
- Cost optimization requires recurring review after real data begins flowing.
- The website team retains ownership of application observability while sharing necessary platform/security signals.

## Implementation guardrails

- Do not send secret values or sensitive request bodies to logs.
- Do not deploy diagnostic settings without a declared category inventory.
- Give policy remediation identities only the permissions required to configure diagnostics.
- Protect workspace and diagnostic-setting changes through the platform pipeline.
- Keep personal notification destinations out of committed configuration.
- Do not automatically enable paid plans during validation or pull-request workflows.
- Export a machine-readable inventory of workspaces, sources, destinations, retention, alerts, and paid features.
- Use test alerts or controlled synthetic events to verify notification paths.

## Validation criteria

This decision will be validated by:

- tests for required Activity Log and platform diagnostic settings;
- a diagnostic catalog with owner and purpose for every collected category;
- queries proving expected test events arrive at the intended destination;
- access tests demonstrating workload operators see only intended telemetry;
- alert tests with recorded delivery and response results;
- an ingestion and retention cost estimate for each deployment profile;
- a report listing every enabled Defender plan and Sentinel workspace; and
- a website observability check covering availability, failures, deployment markers, and privacy.

## References

- [Microsoft: Inventory and visibility considerations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/management-platform)
- [Microsoft: Design a Log Analytics workspace architecture](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/workspace-design)
- [Microsoft: Cost optimization in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/best-practices-cost)
- [Microsoft: Azure Monitor cost and usage](https://learn.microsoft.com/en-us/azure/azure-monitor/cost-usage)
- [Microsoft: Connect Azure subscriptions to Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/connect-azure-subscription)
- [Microsoft: Microsoft Sentinel pricing and billing](https://learn.microsoft.com/en-us/azure/sentinel/billing)
