# Delivery Roadmap

This roadmap tracks the complete portfolio outcome. Checkmarks require evidence in the repository; a written intention alone is not completion.

## 1. Requirements and decisions

- [x] Define the fictional organization and project purpose.
- [x] Define measurable success criteria and cost constraints.
- [x] Propose the infrastructure-as-code choice.
- [x] Propose the resource hierarchy and subscription model.
- [x] Propose the identity and access model.
- [x] Approve or revise the proposed decisions.
- [x] Propose governance and Azure Policy strategy.
- [x] Propose networking, DNS, ingress, and egress strategy.
- [x] Propose logging, monitoring, security, and retention strategy.
- [x] Propose naming, tagging, regional placement, and cost controls.
- [x] Propose repository, Terraform state, testing, and CI/CD strategy.

## 2. Repository foundation

- [x] Connect the work to the public GitHub repository.
- [x] Add repository contribution, security, and license files.
- [x] Define Terraform and documentation directory structure.
- [x] Add formatting, linting, and Terraform validation checks.
- [x] Add secret scanning and dependency update configuration.

## 3. Platform implementation

- [x] Implement remote-state bootstrap with Microsoft Entra authentication.
- [x] Implement management-group hierarchy.
- [x] Implement subscription placement and input validation.
- [x] Implement policy definitions, initiatives, and assignments.
- [x] Implement platform identity and role assignments.
- [x] Implement management and monitoring resources.
- [x] Implement cost-conscious connectivity baseline.
- [ ] Implement optional enterprise networking components.

## 4. Automation and validation

- [ ] Add GitHub OIDC bootstrap guidance.
- [ ] Add separate plan and apply workflows.
- [ ] Protect production deployment through a GitHub environment.
- [ ] Add static Terraform tests and policy tests.
- [ ] Add plan-based integration validation.
- [ ] Generate a profile capability/control-gap report.
- [ ] Document deployment, upgrade, recovery, and teardown procedures.

## 5. Website application landing zone

- [ ] Inspect the wedding and honeymoon websites.
- [ ] Select one workload and record the rationale.
- [ ] Define its production and non-production hosting architecture.
- [ ] Implement workload infrastructure and deployment identity.
- [ ] Deploy through the governed landing-zone workflow.
- [ ] Validate inherited policy, identity boundaries, monitoring, and cost controls.
- [ ] Document the onboarding experience and evidence.

## 6. Portfolio release

- [ ] Produce final architecture and identity-flow diagrams.
- [ ] Record tested costs and identify optional cost drivers.
- [ ] Verify that the repository contains no secrets or personal tenant metadata.
- [ ] Run the complete validation suite from a clean checkout.
- [ ] Verify deployment and cleanup in Azure.
- [ ] Publish the repository and release notes.
