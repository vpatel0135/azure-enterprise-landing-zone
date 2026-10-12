# Wedding website onboarding

## Workload selection

The Wedding Guest website is the first application onboarded to the landing zone. The Wedding and Honeymoon repositories are both static websites, but Wedding provides the stronger operating-model demonstration:

- one canonical data source produces separate Guest and Team applications;
- the Guest build uses allowlisted public fields and automated leakage checks;
- the Team build contains operational data that must not be published anonymously; and
- the application has a meaningful production date and update workflow.

This lets the portfolio demonstrate workload classification, environment separation, privacy boundaries, least-privilege deployment, and repeatable delivery—not merely static-file hosting.

## Scope decision

Only the public `guest/index.html` application is in scope for Azure hosting. The private Team application embeds operational data in its generated HTML and currently uses a client-side convenience code rather than server-side authentication. It must not be deployed to a public endpoint until a separately reviewed authentication and authorization design protects the content before download.

Large Team-only audio and archive assets are also excluded from the public deployment. The current Guest artifact is a single static HTML file and fits comfortably within the selected service limits.

## Hosting architecture

Use one Azure Static Web Apps Free resource per environment:

| Environment | Platform-owned resource group | Application resource | Purpose |
|---|---|---|---|
| Non-production | `rg-eus2n-wed-01` | `stapp-eus2n-wed-01` | Deployment and browser validation before promotion |
| Production | `rg-eus2p-wed-01` | `stapp-eus2p-wed-01` | Public Wedding Guest website |

Azure Static Web Apps Free is appropriate because Microsoft documents globally distributed static hosting, GitHub integration, automatically renewed TLS, three preview environments, 100 GB included monthly bandwidth per subscription, and a 250 MB per-app limit. The service also supports custom domains with automatically created TLS certificates. These limits must still be monitored; the Free plan has no paid bandwidth overage path and no production SLA.

The generated Azure hostname is used first. A custom domain is added only after the deployment is validated and the DNS owner approves the change.

## Ownership boundary

The landing-zone repository owns:

- production and non-production resource groups;
- governed tags and policy inheritance;
- the `sg-wed-operators` human access group; and
- environment-scoped RBAC boundaries.

The Wedding application repository owns:

- the Static Web Apps resources inside those resource groups;
- the Guest build and privacy tests;
- separate application state for production and non-production;
- environment-specific GitHub OIDC plan/apply identities; and
- deployment workflows and release evidence.

Application automation will not receive subscription-wide roles. Each apply identity is scoped to its environment resource group and its own Terraform state container. Production and non-production identities, state, and GitHub environments remain separate.

## Delivery flow

1. Pull-request validation rebuilds the Guest artifact and runs its privacy/regression tests without Azure credentials.
2. Trusted planning uses an environment-specific read-only OIDC identity.
3. Non-production apply deploys through a GitHub environment and its non-production identity.
4. Browser checks validate the Azure hostname and confirm the Team application and private assets are absent.
5. Production requires a fresh plan and an explicit protected-environment approval.
6. Post-deployment evidence records the commit, workflow run, Azure resource, public URL, and validation result.

## Cost and control notes

- Static Web Apps Free has no fixed hosting charge within its documented limits.
- Custom DNS is optional; an existing external DNS provider can be used.
- Azure Front Door, CDN, WAF, private endpoints, and Standard Static Web Apps are not enabled for this lab deployment.
- Monitoring begins with platform activity logs, GitHub deployment evidence, and availability checks; paid telemetry is added only if its operational value is demonstrated.

## References

- [Azure Static Web Apps hosting plans](https://learn.microsoft.com/azure/static-web-apps/plans)
- [Azure Static Web Apps quotas](https://learn.microsoft.com/azure/static-web-apps/quotas)
- [Custom domains with Azure Static Web Apps](https://learn.microsoft.com/azure/static-web-apps/custom-domain)
