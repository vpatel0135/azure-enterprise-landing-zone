# Wedding workload foundation

This root creates the Wedding production and non-production resource groups, governed tags, the `sg-wed-operators` Microsoft Entra group, and resource-group-scoped Contributor assignments. Application code and application-specific infrastructure remain in the Wedding repository.

The lab profile places both environments in the Azure Free Trial subscription while preserving independent resource groups and one isolated `wedding.tfstate` file. The enterprise profile maps the same environments to separate production and non-production subscriptions.

Four GitHub OIDC identities keep production/non-production and plan/apply permissions separate. Plan identities receive Reader on one environment resource group and state-reader access to one container. Apply identities receive Contributor on one environment resource group and state-contributor access to one container. Production and non-production applies trust distinct GitHub environment subjects; no Wedding identity receives subscription-wide access.
