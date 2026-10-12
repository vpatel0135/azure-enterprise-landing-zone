# GitHub OIDC bootstrap

## Purpose

GitHub Actions authenticates to Azure with short-lived OpenID Connect tokens. No Azure client secret or certificate private key is stored in GitHub.

## Current lab state

The deployed `id-alz-platform-plan` identity trusts only this repository's `main` branch. It has:

- Reader on the `alz-example` management group; and
- Storage Blob Data Reader on the organization, management, and connectivity state containers.

It has no Azure write role. Pull requests continue to run offline validation only; unreviewed pull-request code cannot request this Azure identity.

The write-capable `id-alz-platform-apply` design exists in Terraform but is disabled by default. Enabling it creates a persistent external trust with subscription and management-group write access and therefore requires an explicit privileged-access decision. Bootstrap and identity state remain human-operated.

## Repository variables

Configure these GitHub Actions variables without committing their values:

| Variable | Purpose |
|---|---|
| `AZURE_PLAN_CLIENT_ID` | Client ID of `id-alz-platform-plan` |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Lab subscription ID |
| `TF_STATE_RESOURCE_GROUP` | Terraform state resource group |
| `TF_STATE_STORAGE_ACCOUNT` | Terraform state storage account |

These identifiers are not authentication secrets, but this public example keeps personal tenant metadata out of source control. The federated credential—not knowledge of the IDs—is what authorizes token exchange.

## Trust boundaries

- Issuer: `https://token.actions.githubusercontent.com`
- Audience: `api://AzureADTokenExchange`
- Plan subject: `repo:vpatel0135/azure-enterprise-landing-zone:ref:refs/heads/main`
- Apply subject when explicitly enabled: `repo:vpatel0135/azure-enterprise-landing-zone:environment:platform-apply`

Do not broaden the subject to all branches or pull requests. Forked pull requests must never receive Azure credentials.

## Recovery

If federation fails, verify the exact repository owner/name, subject, issuer, audience, and GitHub variables. Do not create a client secret as a shortcut. An authorized human can continue using the documented local bootstrap path while federation is repaired.
