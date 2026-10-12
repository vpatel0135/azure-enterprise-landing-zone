# Management and monitoring layer

This Terraform root deploys the lab's central platform-monitoring boundary:

- `rg-eus2p-mgmt-01`, the management resource group;
- `law-eus2p-mgmt-01`, a pay-as-you-go Log Analytics workspace; and
- a subscription Activity Log diagnostic setting for selected control-plane and health categories.

The lab intentionally omits Microsoft Sentinel, paid Defender plans, data export, long-term retention, alert rules without a real receiver, and workload Application Insights resources. Those features are enabled only when an owner, response route, and accepted cost exist.

## Cost safeguards

- Workspace retention is 30 days.
- A 0.1 GB/day cap protects against unexpected ingestion spikes. A cap is an emergency guardrail and can create visibility gaps; it is not normal capacity management.
- Only low-volume subscription Activity Log categories with a declared platform purpose are collected.
- No data sources, agents, solutions, or paid security plans are attached by default.

## Deployment

Copy the example backend and variable files to their ignored local equivalents, initialize the root, review the plan, and apply it through an authorized platform identity. Personal tenant and subscription identifiers must remain outside committed files.

After deployment, use a controlled Azure change to confirm an `AzureActivity` record reaches the workspace. Query and notification tests may take several minutes and should be recorded as deployment evidence.
