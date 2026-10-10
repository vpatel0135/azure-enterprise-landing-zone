# Terraform state bootstrap

This root creates the Azure resource group, storage account, and private blob containers used by the platform Terraform backends.

## Safety model

- Azure authentication uses an interactive authorized administrator for initial bootstrap and Microsoft Entra ID for backend access.
- Storage shared-key authentication and anonymous blob access are disabled.
- Blob and container soft deletion are retained for 14 days, and blob versioning is enabled.
- Public network access is enabled in the initial lab so a local machine and GitHub-hosted runners can reach the endpoint. Disable it only after a tested private runner and DNS path exists.
- State is sensitive. Never commit state, populated variable files, backend files containing personal identifiers, or plan files.

## Initial deployment

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the placeholder identifiers locally.
2. Authenticate to the intended tenant and subscription, then verify both before continuing.
3. Run `terraform init -backend=false` so the bootstrap begins with local state.
4. Run `terraform plan -out bootstrap.tfplan` and review the target subscription, names, tags, security settings, and cost.
5. Run `terraform apply bootstrap.tfplan`.
6. Copy `backend.hcl.example` to `backend.hcl` and replace its values with the verified outputs.
7. Run `terraform init -migrate-state -backend-config=backend.hcl`.
8. Confirm the state blob exists and run another plan. The expected result is no changes.
9. Test storage version recovery before relying on the backend for production use.

If Azure reports that the storage-account name is unavailable, increment `instance`, create a new plan, and review it. Do not automate global-name probing.
