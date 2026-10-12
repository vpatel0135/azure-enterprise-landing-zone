# Connectivity baseline deployment evidence

## Outcome

The East US 2 low-cost hub-and-spoke demonstration was deployed on 2026-10-11 using dedicated remote Terraform state. A post-deployment plan reported no changes.

The deployed topology contains:

| Role | VNet | Address space | Subnet |
|---|---|---|---|
| Regional hub | `vnet-eus2p-conn-01` | `10.100.0.0/22` | `snet-shared-01` (`10.100.0.0/24`) |
| Non-production demonstration spoke | `vnet-eus2n-demo-01` | `10.100.16.0/20` | `snet-workload-01` (`10.100.16.0/24`) |

Both subnets have an associated network security group and explicitly disable Azure default outbound access.

## Peering verification

Live Azure inspection showed both peerings in `Connected` state:

- `peer-hub-to-demo`
- `peer-demo-to-hub`

Both directions have forwarded traffic, gateway transit, and remote gateway use disabled. No transitive or production-to-non-production route was introduced.

## Cost and exposure boundary

- No public IP address was created.
- No Azure Firewall, network virtual appliance, VPN/ExpressRoute gateway, NAT Gateway, DNS Private Resolver, DDoS Network Protection plan, or Virtual WAN resource was created.
- No private endpoint or private DNS zone was created without a client and resolution requirement.
- VNet peering has no fixed appliance charge but can incur usage-based data-transfer charges if traffic is generated.
- The future public website remains in the `isolated-online` profile and is not connected to the demonstration hub.

## Validation performed

- Terraform validation succeeded.
- The topology test passed against the reviewed non-overlapping address allocations.
- TFLint completed without findings.
- The address catalog is valid JSON.
- Live VNet, subnet, outbound-access, and peering settings matched the configuration.
- A final Terraform plan reported zero drift.
