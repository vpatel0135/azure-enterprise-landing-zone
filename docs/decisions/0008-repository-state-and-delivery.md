# ADR-0008: Isolate State and Separate Validation from Deployment

- **Status:** Proposed
- **Date:** 2026-10-05
- **Decision owner:** Repository maintainer

## Context

The landing zone and its first workload have different owners, permissions, change rates, and failure domains. Storing all resources in one Terraform state or granting one GitHub identity permission to plan and apply everything would make the example simple but would undermine the operating model established by earlier decisions.

The repository also needs useful checks without requiring Azure credentials for every contribution. Tests that create infrastructure can incur costs and leave resources behind if cleanup fails, so they need a distinct execution path and disposable scope.

## Decision drivers

- Keep architecture, platform code, workload onboarding, and validation discoverable in one portfolio repository.
- Limit state and identity blast radius.
- Allow offline checks on every pull request.
- Ensure untrusted pull-request code cannot obtain an Azure write token.
- Produce a reviewable plan before every apply.
- Require human approval for production and privileged platform changes.
- Promote the same code between environments using configuration, not copied directories.
- Make bootstrap, deployment, recovery, and teardown reproducible.
- Pin tool and dependency versions for predictable builds.

## Decision

Use a **monorepo** containing documentation, reusable Terraform modules, independently deployable root modules, tests, and GitHub Actions workflows.

Use separate Azure Blob state keys and separate deployment identities for privileged platform layers and workload environments. Pull requests run offline checks universally and authenticated read-only plans only in trusted contexts. Applies run only after merge or explicit dispatch through protected GitHub environments.

## Repository structure

```text
.
├── .github/
│   ├── workflows/
│   └── dependabot.yml
├── docs/
│   ├── decisions/
│   ├── diagrams/
│   ├── operations/
│   └── evidence/
├── bootstrap/
│   └── terraform-state/
├── modules/
│   ├── management-groups/
│   ├── policy/
│   ├── naming/
│   ├── monitoring/
│   ├── connectivity/
│   └── application-landing-zone/
├── platform/
│   ├── organization/
│   ├── management/
│   └── connectivity/
├── workloads/
│   └── website/
│       ├── nonprod/
│       └── prod/
├── tests/
│   ├── policy/
│   ├── repository/
│   └── integration/
├── examples/
│   ├── lab/
│   └── enterprise/
└── scripts/
```

Reusable modules contain no environment-specific backend configuration. Root modules compose them with profile and environment inputs. Production and non-production use the same module source at the same reviewed commit; only controlled input values and state targets differ.

## State boundaries

Proposed independently managed states:

| State | Contents | Typical identity scope |
|---|---|---|
| `bootstrap` | State resource group, storage account, container, and related access | Temporary bootstrap privilege |
| `organization` | Management groups, policy definitions/initiatives/assignments, selected organization RBAC | Management-group scopes |
| `management` | Central monitoring and management resources | Management subscription |
| `connectivity` | Hub, DNS, peerings, and selected network services | Connectivity and approved spoke scopes |
| `website-nonprod` | Non-production application landing-zone and hosting resources | Website non-production subscription |
| `website-prod` | Production application landing-zone and hosting resources | Website production subscription |

The final split can add a dedicated identity/RBAC state if implementation proves that Entra permissions or ownership separation require it. States are not split merely by resource type; each boundary must correspond to privilege, ownership, lifecycle, or blast radius.

### Remote state

- Store deployment state in a dedicated Azure Storage account created by the bootstrap layer.
- Authenticate to the AzureRM backend with Microsoft Entra ID.
- Disable public access patterns that are not required by the selected runner architecture.
- Enable appropriate storage data protection such as versioning and soft-delete settings after testing their recovery behavior.
- Grant state access per root module and deployment identity; workload pipelines cannot read platform state broadly.
- Do not expose entire remote-state outputs as a cross-layer integration mechanism.
- Publish only intentionally non-sensitive interfaces, using explicit configuration or narrowly scoped outputs.

Terraform state must always be treated as sensitive even when individual variables and outputs are marked `sensitive`.

## Bootstrap

State storage cannot use itself as a backend during its first creation. Use a small, separately documented bootstrap root that starts with local state, creates the remote-state resources, migrates its own state after verification, and records recovery steps.

Bootstrap must:

- run only with an explicitly authorized human or protected bootstrap identity;
- verify the target tenant and subscription before creating resources;
- never commit local state or backend secrets;
- reduce or remove temporary high privilege after setup; and
- test state recovery before production use.

## Branch and change strategy

- Use trunk-based development with short-lived feature branches.
- Protect `main` once the initial repository bootstrap is published.
- Require pull requests, successful required checks, and resolved review comments for normal changes.
- Avoid long-lived environment branches.
- Treat generated plans as review artifacts tied to a specific commit; never apply a stale plan after code or inputs change.
- Use dependency automation to propose version updates, but do not merge provider or action upgrades without validation.

The initial documentation commits on an unpublished empty repository are bootstrap history, not the steady-state delivery model.

## Identity and workflow separation

GitHub Actions uses OpenID Connect federated credentials. No Azure client secret is stored in GitHub.

| Workflow context | Identity | Permission intent |
|---|---|---|
| Offline pull-request checks | None | No Azure access |
| Trusted platform plan | Platform plan identity | Read-only plus minimum permissions needed to evaluate configuration |
| Approved platform apply | Platform apply identity | Narrow platform write roles |
| Trusted non-production plan/apply | Non-production workload identities | Non-production scope only |
| Trusted production plan | Production plan identity | Production read-only scope |
| Approved production apply | Production apply identity | Production workload write scope only |

Federated subjects are restricted to the expected repository and GitHub environment or branch. Platform and workload identities are not shared. Production and non-production identities are not shared.

Forked or otherwise untrusted pull requests run offline checks only. Workflows triggered by pull-request code must not automatically execute privileged code with write credentials.

## Workflow model

### Pull request

Required offline checks:

- Markdown and repository-structure checks;
- secret scanning;
- Terraform format check;
- `terraform init -backend=false` and `terraform validate` for each root/module where applicable;
- Terraform native tests that use mocked providers or plan-only behavior;
- policy and configuration assertions; and
- static security analysis with documented suppressions.

Trusted internal pull requests may also generate read-only plans. Plans are summarized for reviewers, while full artifacts are retained with controlled access because plan files can contain sensitive values.

### Merge to `main`

- Re-run validation against the exact merged commit.
- Generate a fresh plan; do not reuse a plan from an earlier commit.
- Apply non-production only through its designated environment and identity.
- Apply privileged platform layers through a protected environment, even when the change appears small.
- Record commit, workflow, identity, plan, apply result, and resulting state version as deployment evidence.

### Production

- Require protected-environment approval.
- Generate and review a fresh production plan.
- Verify the expected tenant, subscription, and state key before apply.
- Prevent concurrent applies to the same state.
- Run post-deployment validation and publish evidence.
- Do not promote merely because non-production deployment completed; required checks must pass.

## Test layers

| Layer | Purpose | Azure resources |
|---|---|---|
| Formatting/static validation | Syntax, style, repository invariants | None |
| Terraform native unit tests | Module logic, validations, conditional resources | None when providers are mocked/plan-only |
| Plan assertions | Intended resources, scopes, names, tags, and forbidden configurations | Read access may be required |
| Policy tests | Definition structure, initiative membership, exemptions, expected deny behavior | None for static tests; isolated scope for enforcement tests |
| Integration tests | Actual Azure behavior, identity, policy inheritance, networking, monitoring | Disposable test subscription/resource groups |
| End-to-end tests | Subscription onboarding and website promotion | Dedicated controlled environment |

Any test capable of creating resources is opt-in, has a budget, uses a dedicated scope, records created resources, and verifies cleanup. A failed cleanup is a test failure requiring investigation, not a warning to ignore.

## Rollback and recovery

Terraform rollback is normally a forward change that restores the prior desired configuration. Do not assume reverting Git automatically reverses resource mutations safely.

Every root module needs:

- state backup and recovery guidance;
- import guidance for recoverable drift;
- documented handling for moved/renamed resources;
- destructive-change review rules;
- post-apply verification; and
- a teardown procedure that respects dependencies and retained evidence.

Manual state push, forced unlock, import, state move, and resource replacement are break-glass operations documented separately and never embedded in ordinary CI.

## Supply-chain controls

- Pin Terraform and provider version ranges and commit the dependency lock files for root modules.
- Pin GitHub Actions to immutable commit SHAs, with human-readable version comments.
- Prefer Azure Verified Modules where appropriate and record module versions.
- Review dependency provenance and licenses.
- Limit GitHub workflow permissions by default and grant `id-token: write` only to jobs using OIDC.
- Prevent generated plan files, state, crash logs, variable secrets, and local override files from being committed.
- Run secret scanning before commit and in CI.

## Options considered

### Separate repository for every platform layer

Rejected initially. It would obscure the end-to-end portfolio story and add release coordination without multiple owning teams. State and identity isolation provide the required runtime boundaries.

### One Terraform root and state

Rejected. It gives ordinary workload changes an unnecessarily large blast radius and creates broad state access.

### One identity for plan and apply

Rejected. Pull-request evaluation does not need mutation privileges.

### Apply pull-request plans automatically

Rejected. Pull-request code and plans can become stale or untrusted, and production changes require approval.

### Local-machine production applies

Rejected as the steady-state workflow. They are difficult to govern, reproduce, and audit.

### Run Azure integration tests on every pull request

Rejected. It adds credential exposure, time, cost, quota usage, and cleanup risk. Static and mocked tests run universally; integration tests use controlled trusted workflows.

## Consequences

- The repository remains easy to explore while deployment blast radii are separated.
- More than one state and identity must be bootstrapped and maintained.
- Cross-layer interfaces must be explicit rather than relying on unrestricted remote-state access.
- CI can provide meaningful feedback without Azure credentials.
- Full integration evidence costs time and Azure resources and therefore runs selectively.
- GitHub environment protection becomes part of the production control plane.

## Implementation guardrails

- Never commit state, plan files, `.terraform` directories, credentials, or populated personal variable files.
- Never apply a plan produced for a different commit, state key, tenant, or subscription.
- Never expose an apply identity to untrusted pull-request code.
- Validate target tenant, subscription, and state before all authenticated operations.
- Serialize applies per state boundary.
- Keep workflow permissions explicit and minimal.
- Fail integration workflows when cleanup cannot be proven.
- Preserve logs and evidence without leaking sensitive plan or state content.

## Validation criteria

This decision will be validated by:

- repository tests for the expected root/module structure;
- a test proving production and non-production use different state keys and client IDs;
- backend access tests demonstrating workload identities cannot read platform state;
- pull-request workflow inspection proving it has no Azure write path;
- protected-environment evidence for platform and production applies;
- concurrent-apply locking tests;
- state recovery and disposable-environment cleanup exercises; and
- a clean-checkout run of the documented validation suite.

## References

- [Microsoft: Platform automation and DevOps](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/platform-automation-devops)
- [Microsoft: Use infrastructure as code to update Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/infrastructure-as-code-updates)
- [Microsoft: Testing approach for Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/testing-approach)
- [HashiCorp: Terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)
- [HashiCorp: Terraform test](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Microsoft: Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
