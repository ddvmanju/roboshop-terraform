terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features{}
  subscription_id = "00f9828e-4aad-42e5-ac92-a3c54883cbd3"
}