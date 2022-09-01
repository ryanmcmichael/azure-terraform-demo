# Create the VNET
resource "azurerm_virtual_network" "app" {
  name                = "${var.environment}-app"
  address_space       = ["10.${var.subnet_prefix}.0.0/16"]
  location            = var.region
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "snet_mgmt" {
  name                    = "snet-mgmt"
  resource_group_name     = var.resource_group
  virtual_network_name    = azurerm_virtual_network.app.name
  address_prefixes        = ["10.${var.subnet_prefix}.0.0/24"]
}

resource "azurerm_subnet" "snet_public" {
  name                    = "snet-public"
  resource_group_name     = var.resource_group
  virtual_network_name    = azurerm_virtual_network.app.name
  address_prefixes        = ["10.${var.subnet_prefix}.1.0/24"]
  service_endpoints       = local.AZURE_ENDPOINTS
}

resource "azurerm_subnet" "snet_private" {
  name                    = "snet-private"
  resource_group_name     = var.resource_group
  virtual_network_name    = azurerm_virtual_network.app.name
  address_prefixes        = ["10.${var.subnet_prefix}.2.0/24"]
  service_endpoints       = local.AZURE_ENDPOINTS

  delegation {
    name = "serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
