# ADR-0005: Use Requirement-Driven Regional Hub-and-Spoke Connectivity

- **Status:** Proposed
- **Date:** 2026-10-05
- **Decision owner:** Repository maintainer

## Context

An Azure landing zone needs a scalable connectivity model, but not every workload needs a virtual network or access to a shared hub. The first workload is a public website in the Online archetype. Forcing it through an always-on firewall, gateway, or Virtual WAN hub would add cost and operational coupling without a stated hybrid or east-west connectivity requirement.

The fictional organization still needs a credible target for future internal workloads, private endpoints, shared DNS, and optional hybrid connectivity. The design must therefore demonstrate enterprise boundaries without deploying expensive network appliances simply to make the diagram look complete.

## Decision drivers

- Support a medium-sized organization initially operating in one Azure region.
- Keep public Online workloads isolated unless they have an explicit private dependency.
- Provide shared connectivity for Corp and other connected workload spokes.
- Avoid mandatory hourly-cost services when no traffic requirement justifies them.
- Preserve a clear evolution path to hybrid and multi-region connectivity.
- Centralize address planning and private DNS where central ownership adds value.
- Keep workload teams responsible for application-specific network security.
- Make every route and trust relationship intentional and testable.

## Decision

Use a **traditional regional hub-and-spoke topology** as the default topology for workloads that require shared or hybrid connectivity.

Do not require every application landing zone to connect to the hub. An Online subscription can use platform services without Layer 3 connectivity to platform or Corp networks. The website remains disconnected from the hub unless its selected hosting architecture later introduces a justified private dependency.

### Target topology

```text
Internet
   │
   ├── Approved public application edge
   │       └── Online workload (website)
   │             No hub route by default
   │
   └── Optional inspected ingress/egress
             │
Connectivity subscription
└── Regional hub VNet
    ├── Optional Azure Firewall or approved NVA
    ├── Optional VPN/ExpressRoute gateway
    ├── Private DNS zones and optional DNS resolver
    └── Peering
        ├── Corp workload spoke A
        ├── Corp workload spoke B
        └── Online spoke only when explicitly required
```

### Why traditional hub-and-spoke

The working scenario is regional and does not require large-scale branch connectivity, global transit, or managed any-to-any routing. Traditional hub-and-spoke makes peering, routes, and optional appliances visible to a portfolio reviewer and has a lower starting footprint.

Azure Virtual WAN is the documented scale-up option when the organization needs managed global transit, many branches, several regions, or reduced routing-management overhead. Migrating to it is a future architecture decision, not a hidden feature flag.

## Connectivity profiles

Profiles express capability rather than pretending all environments need identical network services.

### `isolated-online`

For internet-facing PaaS or static workloads without private dependencies:

- no hub peering;
- no forced tunnel through a central firewall;
- application edge and origin controls are workload-owned;
- outbound behavior depends on the selected service;
- private endpoints are not added without corresponding DNS and connectivity design.

This is the expected starting profile for the website.

### `connected-spoke`

For a workload requiring shared services or private connectivity:

- workload VNet in the workload subscription;
- peering to the regional hub;
- non-overlapping centrally allocated address space;
- subnet-level network security and route tables where required;
- no spoke-to-spoke connectivity by default; and
- access to private DNS zones relevant to the workload.

Corp workloads normally use this profile.

### `secured-hub`

An enterprise extension of `connected-spoke`:

- Azure Firewall or an approved network virtual appliance;
- user-defined routes for traffic that must be inspected;
- centralized egress policy and diagnostic logging; and
- workload-specific exceptions rather than unrestricted bypass routes.

This profile is optional because a firewall has ongoing cost and operational consequences. It is selected from a traffic-inspection requirement, not from landing-zone branding.

### `hybrid`

Adds VPN or ExpressRoute gateway connectivity to the secured or unfiltered hub. It requires an actual on-premises address plan, routing design, availability requirement, and ownership model. Placeholder gateways are not deployed in the portfolio lab.

## Address management

- Keep an environment-neutral IP allocation catalog in version control.
- Allocate a unique regional hub range and non-overlapping spoke ranges.
- Avoid assigning addresses based solely on subscription names; record region, workload, environment, and allocation status.
- Reserve expansion space rather than filling a hub or spoke range on first deployment.
- Validate overlap in Terraform and in repository tests before planning Azure resources.
- Treat address changes as potentially destructive once resources exist.

Example documentation ranges will use RFC 1918 addresses and will not reveal a real corporate network plan.

## DNS

- Public website DNS remains authoritative in the selected public DNS/edge service and is decided with the workload architecture.
- Private DNS zones used by private endpoints are owned centrally in the Connectivity subscription when multiple landing zones need consistent resolution.
- Link private zones only to networks that need them; do not create tenant-wide implicit reachability.
- Use Azure DNS Private Resolver only when conditional forwarding or hybrid name resolution is required.
- Keep private DNS zone registration disabled unless a specific zone and workload require automatic registration.
- Document split-horizon behavior before reusing a public namespace privately.

## Inbound connectivity

- Public HTTP/S ingress terminates at an approved Layer 7 edge selected by the workload architecture.
- Do not expose VM management ports to the internet.
- Public IP addresses require an explicit workload need and policy treatment appropriate to Online or Corp.
- A web application firewall is selected according to application risk and cost; it is not represented as free or enabled when absent.
- Origin access should be restricted to the chosen edge service where the Azure service supports that pattern.

## Outbound connectivity

- Do not rely on implicit/default outbound access for compute resources.
- An isolated Online workload that needs stable outbound IP but not centralized inspection uses a NAT Gateway or a service-native outbound mechanism when justified.
- Connected spokes use the hub inspection path only in the `secured-hub` profile.
- Private endpoints do not automatically eliminate all public egress; service dependencies must be inventoried.
- Network rules supplement identity controls and do not replace managed identity or least-privilege authorization.

## Routing and segmentation

- VNet peering is non-transitive; any intended transit path is explicitly implemented.
- Spokes cannot route directly to other spokes by default.
- Route tables declare traffic inspection or gateway propagation behavior; undocumented routes are not accepted.
- Production and non-production remain isolated even when both connect to a hub. Connectivity requires explicit rules and a documented use case.
- Network Security Groups are applied at appropriate subnet boundaries and do not use broad inbound Internet rules.
- Platform teams own hub resources and peering; workload teams own their spoke subnets and application-level controls within guardrails.

## Cost behavior

The code will separate no/low-fixed-cost constructs from services with ongoing charges.

| Capability | Default lab state | Enterprise option |
|---|---|---|
| Hub VNet and route-table definitions | Deployable | Enabled when connected workloads exist |
| VNet peering | Only for a connected-spoke demonstration | Enabled per approved spoke |
| Azure Firewall/NVA | Off | `secured-hub` profile |
| VPN/ExpressRoute gateway | Off | `hybrid` profile |
| Azure Virtual WAN | Off | Future architecture for scale requirements |
| DNS Private Resolver | Off | Enabled for hybrid/conditional forwarding |
| NAT Gateway | Off unless workload requires it | Enabled per workload egress requirement |
| DDoS Network Protection | Off in personal lab | Evaluated for protected public VNets |

Actual prices vary by region, SKU, usage, and date. The repository will link to the Azure pricing calculator and capture deployment-specific estimates rather than hard-code promises.

## Options considered

### Azure Virtual WAN as the default

Rejected for the initial scenario. Its managed transit benefits are valuable at multi-region and branch scale, but those requirements do not exist here and its hub introduces ongoing cost.

### Mandatory secured hub for every workload

Rejected. It couples isolated PaaS workloads to centralized network infrastructure and incurs cost without evidence that all traffic needs inspection.

### Flat workload networks with no enterprise topology

Rejected as the target architecture. It does not provide a governed path for private, shared-service, or hybrid-connected workloads.

### Peer every Online workload to the hub

Rejected. Public-facing classification does not imply a need for corporate reachability. Connectivity is granted from requirements, not management-group placement alone.

### Single shared VNet for multiple workloads

Rejected. It weakens ownership and blast-radius boundaries and conflicts with subscription-aligned workload isolation.

## Consequences

- The initial website can remain simple and inexpensive without weakening the enterprise connectivity design.
- The Connectivity subscription might intentionally contain few or no runtime resources in a minimal deployment.
- Some reviewers may expect to see a firewall; documentation must clearly explain why it is optional and show the secured profile.
- Private endpoints require deliberate DNS and client-connectivity design.
- Supporting multiple profiles adds validation work but keeps cost and capability honest.
- Multi-region or large branch requirements trigger a future comparison with Virtual WAN.

## Implementation guardrails

- Never create overlapping hub or spoke CIDRs.
- Do not permit `0.0.0.0/0` inbound security rules except narrowly defined public-service paths reviewed by policy tests.
- Do not create peering between production and non-production spokes as a shortcut.
- Do not enable gateway transit unless a gateway exists and the routing requirement is documented.
- Do not create private endpoints without private DNS resolution and an identified client path.
- Export intended routes, peerings, DNS links, and public endpoints as reviewable inventories.
- Keep firewall, gateways, resolvers, NAT gateways, and DDoS plans disabled unless their profile is selected.

## Validation criteria

This decision will be validated by:

- CIDR overlap and reserved-range tests;
- topology tests for expected and forbidden peerings;
- route-table and effective-route inspection for connected profiles;
- DNS resolution tests from each intended client network;
- negative tests proving production/non-production and spoke/spoke isolation;
- an inventory of public endpoints and permitted ingress paths;
- a cost-capability report for each selected profile; and
- a documented exercise that adds one connected Corp spoke without redesigning the hierarchy.

## References

- [Microsoft: Network topology and connectivity for Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity)
- [Microsoft: Define an Azure network topology](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/define-an-azure-network-topology)
- [Microsoft: Traditional Azure networking topology](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/traditional-azure-networking-topology)
- [Microsoft: Hub-and-spoke network topology](https://learn.microsoft.com/en-us/azure/networking/design-guide/hub-spoke)
- [Microsoft: Plan inbound and outbound internet connectivity](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-inbound-and-outbound-internet-connectivity)
