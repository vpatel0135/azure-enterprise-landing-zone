output "virtual_network_ids" {
  description = "Virtual network resource IDs keyed by topology role."
  value       = { for key, network in azurerm_virtual_network.network : key => network.id }
}

output "peering_inventory" {
  description = "Reviewable peering inventory for the low-cost connected-spoke profile."
  value = {
    hub_to_demo = {
      name              = azurerm_virtual_network_peering.hub_to_demo.name
      forwarded_traffic = azurerm_virtual_network_peering.hub_to_demo.allow_forwarded_traffic
      gateway_transit   = azurerm_virtual_network_peering.hub_to_demo.allow_gateway_transit
      remote_gateway    = azurerm_virtual_network_peering.hub_to_demo.use_remote_gateways
    }
    demo_to_hub = {
      name              = azurerm_virtual_network_peering.demo_to_hub.name
      forwarded_traffic = azurerm_virtual_network_peering.demo_to_hub.allow_forwarded_traffic
      gateway_transit   = azurerm_virtual_network_peering.demo_to_hub.allow_gateway_transit
      remote_gateway    = azurerm_virtual_network_peering.demo_to_hub.use_remote_gateways
    }
  }
}
