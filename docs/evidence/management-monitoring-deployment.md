# Management and monitoring deployment evidence

## Outcome

The lab management root was deployed on 2026-10-11 using its dedicated remote Terraform state. A post-deployment refresh reported no changes.

The deployment created:

- resource group `rg-eus2p-mgmt-01` in East US 2;
- Log Analytics workspace `law-eus2p-mgmt-01`; and
- subscription diagnostic setting `diag-subscription-activity-law`.

## Live configuration verified

| Setting | Verified value |
|---|---|
| Workspace SKU | `PerGB2018` pay-as-you-go |
| Retention | 30 days |
| Emergency ingestion cap | 0.1 GB/day |
| Local authentication | Disabled |
| Activity Log categories | Administrative, Alert, Policy, Recommendation, ResourceHealth, Security, ServiceHealth |

The first `AzureActivity` query immediately after deployment returned zero records. Azure diagnostic ingestion is asynchronous, so end-to-end record arrival remains an operational follow-up rather than being misreported as complete.

## Cost and security boundaries

- Microsoft Sentinel is disabled.
- Paid Microsoft Defender plans are disabled.
- Long-term retention, data export, agents, solutions, and high-volume workload logs are not configured.
- No alert rule was created without an owned notification route and response procedure.
- Application Insights remains a workload-onboarding concern and was not created before an application exists.
- The daily cap is treated as an emergency safeguard; reaching it creates a monitoring gap and can still allow some billable overage while Azure processes the cap.

## Validation performed

- Terraform validation succeeded without deprecated arguments.
- The cost-conscious monitoring test passed.
- TFLint completed without findings.
- The diagnostic catalog is valid JSON.
- Live Azure configuration matched the intended SKU, retention, cap, authentication, and category inventory.
- A final Terraform plan reported zero drift.
