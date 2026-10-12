locals {
  networks = {
    hub = {
      resource_group_name = "rg-eus2p-conn-01"
      vnet_name           = "vnet-eus2p-conn-01"
      vnet_cidr           = "10.100.0.0/22"
      subnet_name         = "snet-shared-01"
      subnet_cidr         = "10.100.0.0/24"
      nsg_name            = "nsg-eus2p-conn-01"
      environment         = "production"
      application         = "platform-connectivity"
      criticality         = "high"
    }
    demo = {
      resource_group_name = "rg-eus2n-demo-01"
      vnet_name           = "vnet-eus2n-demo-01"
      vnet_cidr           = "10.100.16.0/20"
      subnet_name         = "snet-workload-01"
      subnet_cidr         = "10.100.16.0/24"
      nsg_name            = "nsg-eus2n-demo-01"
      environment         = "nonproduction"
      application         = "connected-spoke-demo"
      criticality         = "low"
    }
  }

  required_tags = {
    for key, network in local.networks : key => {
      application         = network.application
      environment         = network.environment
      owner-group         = "sg-alz-platform-operators"
      cost-center         = "portfolio-demo"
      managed-by          = "terraform"
      criticality         = network.criticality
      data-classification = "internal"
    }
  }
}

resource "azurerm_resource_group" "network" {
  for_each = local.networks

  name     = each.value.resource_group_name
  location = var.location
  tags     = merge(var.tags, local.required_tags[each.key])
}

resource "azurerm_virtual_network" "network" {
  for_each = local.networks

  name                = each.value.vnet_name
  resource_group_name = azurerm_resource_group.network[each.key].name
  location            = azurerm_resource_group.network[each.key].location
  address_space       = [each.value.vnet_cidr]
  tags                = merge(var.tags, local.required_tags[each.key])
}

resource "azurerm_network_security_group" "network" {
  for_each = local.networks

  name                = each.value.nsg_name
  resource_group_name = azurerm_resource_group.network[each.key].name
  location            = azurerm_resource_group.network[each.key].location
  tags                = merge(var.tags, local.required_tags[each.key])
}

resource "azurerm_subnet" "network" {
  for_each = local.networks

  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.network[each.key].name
  virtual_network_name = azurerm_virtual_network.network[each.key].name
  address_prefixes     = [each.value.subnet_cidr]

  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet_network_security_group_association" "network" {
  for_each = local.networks

  subnet_id                 = azurerm_subnet.network[each.key].id
  network_security_group_id = azurerm_network_security_group.network[each.key].id
}

resource "azurerm_virtual_network_peering" "hub_to_demo" {
  name                      = "peer-hub-to-demo"
  resource_group_name       = azurerm_resource_group.network["hub"].name
  virtual_network_name      = azurerm_virtual_network.network["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.network["demo"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "demo_to_hub" {
  name                      = "peer-demo-to-hub"
  resource_group_name       = azurerm_resource_group.network["demo"].name
  virtual_network_name      = azurerm_virtual_network.network["demo"].name
  remote_virtual_network_id = azurerm_virtual_network.network["hub"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
