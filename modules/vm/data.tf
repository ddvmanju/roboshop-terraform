data "azurerm_resource_group" "main" {
  name = "project-setup1"
}

data "azurerm_subnet" "example" {
  name                 = "snet-ukwest-1"
  virtual_network_name = "vnet-ukwest"
  resource_group_name  = data.azurerm_resource_group.main.name
}