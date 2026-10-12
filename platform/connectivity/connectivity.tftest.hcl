mock_provider "azurerm" {}

variables {
  tenant_id       = "00000000-0000-0000-0000-000000000001"
  subscription_id = "00000000-0000-0000-0000-000000000002"
}

run "uses_non_overlapping_low_cost_topology" {
  command = plan

  assert {
    condition     = local.networks.hub.vnet_cidr == "10.100.0.0/22" && local.networks.demo.vnet_cidr == "10.100.16.0/20"
    error_message = "Hub and demonstration spoke must use the reviewed non-overlapping address allocations."
  }

  assert {
    condition     = !azurerm_virtual_network_peering.hub_to_demo.allow_forwarded_traffic && !azurerm_virtual_network_peering.demo_to_hub.allow_forwarded_traffic
    error_message = "The unfiltered lab hub must not enable forwarded traffic."
  }

  assert {
    condition     = !azurerm_virtual_network_peering.hub_to_demo.allow_gateway_transit && !azurerm_virtual_network_peering.demo_to_hub.use_remote_gateways
    error_message = "Gateway transit must remain disabled while no gateway exists."
  }

  assert {
    condition     = length(azurerm_virtual_network.network) == 2 && azurerm_virtual_network_peering.hub_to_demo.name == "peer-hub-to-demo" && azurerm_virtual_network_peering.demo_to_hub.name == "peer-demo-to-hub"
    error_message = "The baseline must contain exactly the reviewed hub and spoke networks."
  }

  assert {
    condition     = alltrue([for subnet in azurerm_subnet.network : !subnet.default_outbound_access_enabled])
    error_message = "Subnets must not rely on Azure default outbound access."
  }
}
