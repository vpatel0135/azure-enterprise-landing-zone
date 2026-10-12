# Wedding workload foundation

This root creates the Wedding production and non-production resource groups, governed tags, the `sg-wed-operators` Microsoft Entra group, and resource-group-scoped Contributor assignments. Application code and application-specific infrastructure remain in the Wedding repository.

The lab profile places both environments in the Azure Free Trial subscription while preserving independent resource groups and one isolated `wedding.tfstate` file. The enterprise profile maps the same environments to separate production and non-production subscriptions.

Application plan/apply identities are intentionally not created here until the Wedding repository name and its protected GitHub environments are known. They will be scoped to one environment resource group and one application state container rather than the subscription.
