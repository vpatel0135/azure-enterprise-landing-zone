# Connectivity layer

This root deploys the East US 2 low-cost `connected-spoke` demonstration:

- hub resource group and `10.100.0.0/22` VNet;
- non-production demonstration resource group and `10.100.16.0/20` spoke VNet;
- one subnet and network security group per VNet; and
- explicit bidirectional peering with forwarded traffic and gateway transit disabled.

The public website will use the separate `isolated-online` profile and is not connected to this hub unless a private dependency is later justified.

Azure Firewall, VPN/ExpressRoute gateway, NAT Gateway, DNS Private Resolver, DDoS Network Protection, Virtual WAN, public IP addresses, and private endpoints are not deployed. The baseline has no fixed hourly network appliance charge; VNet peering can incur usage-based data-transfer charges if traffic is sent.

Copy the example backend and variable files to their ignored local equivalents, initialize, review the plan, and apply using an authorized platform identity.
