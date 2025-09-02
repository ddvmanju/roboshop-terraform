data "azurerm_resource_group" "main" {
  name = "project-setup1"
}

data "azurerm_subnet" "example" {
  name                 = "default"
  virtual_network_name = "DevOps-AMI-vnet"
  resource_group_name  = data.azurerm_resource_group.main.name
}