# ADR-0001: Use Terraform as the Authoritative Infrastructure-as-Code Tool

- **Status:** Proposed
- **Date:** 2026-10-05
- **Decision owner:** Repository maintainer

## Context

This public portfolio project needs one authoritative implementation for the Azure platform landing zone and the website application landing zone. Maintaining equivalent Terraform and Bicep implementations would increase testing and maintenance work while weakening the clarity of the example.

Microsoft supports both Bicep and Terraform for Azure landing zones. Its current guidance recommends the Azure Landing Zones infrastructure-as-code accelerator and Azure Verified Modules for either tool. The choice is therefore about the goals and operating characteristics of this project rather than basic vendor support.

## Decision drivers

- Demonstrate skills that transfer beyond Azure-specific deployments.
- Make plans and infrastructure changes easy for a reviewer to inspect.
- Support management-group, policy, subscription, platform, and workload resources.
- Provide reusable modules for production and non-production.
- Enable automated formatting, validation, security scanning, and tests.
- Avoid duplicating the implementation in two languages.
- Preserve a credible path to Microsoft-supported Azure Verified Modules.

## Options considered

### Terraform

Advantages:

- Broad industry recognition and applicability beyond Azure.
- Explicit plans provide a useful review artifact before changes are applied.
- Strong module ecosystem, including Azure Verified Modules.
- Consistent language across platform and workload infrastructure.
- Azure Blob Storage can provide remote state, state locking, and consistency checking.

Costs and risks:

- Requires carefully secured remote state because state can contain sensitive values.
- Introduces provider versioning and state lifecycle responsibilities.
- Newly released Azure features can appear later in the AzureRM provider; AzAPI may be needed as a bridge.
- Bootstrapping the remote-state storage must be handled separately.

### Bicep

Advantages:

- Azure-native language with direct alignment to Azure Resource Manager.
- No separate Terraform state file to operate.
- Strong resource coverage and concise Azure-specific syntax.
- Azure deployment history and `what-if` integrate naturally with the platform.
- Supported by Azure Verified Modules and the landing-zone accelerator.

Costs and risks:

- Skills and code are primarily Azure-specific.
- Cross-cloud reuse is not a project goal, but demonstrating transferable IaC experience has portfolio value.
- Resource deletion and drift behavior differ from Terraform and require careful deployment-scope and mode choices.

### Maintain both implementations

Advantages:

- Demonstrates familiarity with both ecosystems.
- Gives consumers a choice of deployment tool.

Costs and risks:

- Doubles implementation, testing, documentation, and upgrade work.
- Makes feature parity difficult to prove.
- Encourages shallow examples instead of one complete, well-tested implementation.

## Decision

Use **Terraform** as the single authoritative infrastructure-as-code implementation.

Use Azure Verified Modules where they fit the architecture, but wrap or compose them behind repository-owned modules so that the project remains understandable and its design decisions remain visible. Use the AzureRM provider by default and AzAPI only for a documented coverage gap.

Do not create a parallel Bicep implementation. Bicep may be mentioned in the alternatives and used only if a small bootstrap operation has a compelling technical reason; such an exception requires its own decision record.

## State-management direction

The implementation will use two modes:

1. **Local evaluation mode:** allows formatting, validation, linting, and non-deployment tests without Azure credentials. It must not encourage committing local state.
2. **Azure deployment mode:** stores state in Azure Blob Storage, authenticates with Microsoft Entra ID, and uses separate state keys for independently managed platform and workload layers.

The state bootstrap will be deliberately small and separately documented. CI/CD will use workload identity federation rather than stored client secrets.

## Consequences

- Repository examples, tests, and CI/CD will center on Terraform.
- Provider and module versions will be pinned and updated intentionally.
- State security, backup, access control, and recovery become explicit design responsibilities.
- Pull requests can show validation and plan results before deployment.
- Reviewers see one end-to-end implementation rather than two incomplete variants.

## Validation criteria

This decision is accepted when the maintainer confirms Terraform as the desired portfolio emphasis. It will be validated during implementation by demonstrating:

- successful offline formatting and configuration validation;
- an isolated Azure remote-state bootstrap;
- a plan/apply workflow using federated authentication;
- separate state boundaries for platform and workload layers; and
- documented teardown behavior.

## References

- [Microsoft: Platform landing zone implementation options](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/)
- [Microsoft: Use infrastructure as code to update Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/infrastructure-as-code-updates)
- [Microsoft: Deploy Azure Landing Zones](https://learn.microsoft.com/en-us/azure/architecture/landing-zones/landing-zone-deploy)
- [HashiCorp: AzureRM backend](https://developer.hashicorp.com/terraform/language/backend/azurerm)
