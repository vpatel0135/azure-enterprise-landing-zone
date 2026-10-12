locals {
  management_group_ids = {
    root           = var.management_group_prefix
    platform       = "${var.management_group_prefix}-platform"
    management     = "${var.management_group_prefix}-management"
    connectivity   = "${var.management_group_prefix}-connectivity"
    identity       = "${var.management_group_prefix}-identity"
    landing_zones  = "${var.management_group_prefix}-landing-zones"
    online         = "${var.management_group_prefix}-online"
    corp           = "${var.management_group_prefix}-corp"
    sandboxes      = "${var.management_group_prefix}-sandboxes"
    decommissioned = "${var.management_group_prefix}-decommissioned"
  }

  hierarchy = {
    root           = { display_name = "ALZ Example", parent = null }
    platform       = { display_name = "Platform", parent = "root" }
    management     = { display_name = "Management", parent = "platform" }
    connectivity   = { display_name = "Connectivity", parent = "platform" }
    identity       = { display_name = "Identity", parent = "platform" }
    landing_zones  = { display_name = "Landing Zones", parent = "root" }
    online         = { display_name = "Online", parent = "landing_zones" }
    corp           = { display_name = "Corp", parent = "landing_zones" }
    sandboxes      = { display_name = "Sandboxes", parent = "root" }
    decommissioned = { display_name = "Decommissioned", parent = "root" }
  }

  enterprise_subscription_placements = var.enterprise_subscription_ids == null ? {} : merge(
    {
      management                 = { management_group_key = "management", subscription_id = var.enterprise_subscription_ids.management }
      connectivity               = { management_group_key = "connectivity", subscription_id = var.enterprise_subscription_ids.connectivity }
      webportfolio_production    = { management_group_key = "online", subscription_id = var.enterprise_subscription_ids.webportfolio_production }
      webportfolio_nonproduction = { management_group_key = "online", subscription_id = var.enterprise_subscription_ids.webportfolio_nonproduction }
    },
    var.enterprise_subscription_ids.identity == null ? {} : {
      identity = { management_group_key = "identity", subscription_id = var.enterprise_subscription_ids.identity }
    },
    var.enterprise_subscription_ids.sandbox == null ? {} : {
      sandbox = { management_group_key = "sandboxes", subscription_id = var.enterprise_subscription_ids.sandbox }
    }
  )

  subscription_placements = var.profile == "lab" ? {
    lab = { management_group_key = "root", subscription_id = var.lab_subscription_id }
  } : local.enterprise_subscription_placements
}

resource "azurerm_management_group" "root" {
  name         = local.management_group_ids.root
  display_name = local.hierarchy.root.display_name
}

resource "azurerm_management_group" "platform" {
  name                       = local.management_group_ids.platform
  display_name               = local.hierarchy.platform.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "management" {
  name                       = local.management_group_ids.management
  display_name               = local.hierarchy.management.display_name
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = local.management_group_ids.connectivity
  display_name               = local.hierarchy.connectivity.display_name
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  name                       = local.management_group_ids.identity
  display_name               = local.hierarchy.identity.display_name
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "landing_zones" {
  name                       = local.management_group_ids.landing_zones
  display_name               = local.hierarchy.landing_zones.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "online" {
  name                       = local.management_group_ids.online
  display_name               = local.hierarchy.online.display_name
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "corp" {
  name                       = local.management_group_ids.corp
  display_name               = local.hierarchy.corp.display_name
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "sandboxes" {
  name                       = local.management_group_ids.sandboxes
  display_name               = local.hierarchy.sandboxes.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "decommissioned" {
  name                       = local.management_group_ids.decommissioned
  display_name               = local.hierarchy.decommissioned.display_name
  parent_management_group_id = azurerm_management_group.root.id
}

locals {
  management_group_resource_ids = {
    root         = azurerm_management_group.root.id
    management   = azurerm_management_group.management.id
    connectivity = azurerm_management_group.connectivity.id
    identity     = azurerm_management_group.identity.id
    online       = azurerm_management_group.online.id
    sandboxes    = azurerm_management_group.sandboxes.id
  }
}

resource "azurerm_management_group_subscription_association" "placement" {
  for_each = local.subscription_placements

  management_group_id = local.management_group_resource_ids[each.value.management_group_key]
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
}
