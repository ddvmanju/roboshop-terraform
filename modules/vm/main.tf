resource "azurerm_public_ip" "main" {
  name                = "${var.component}-${var.env}ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    component = "${var.component}-${var.env}-ip"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.component}-${var.env}-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.component}-${var.env}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "main"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    component = "${var.component}-${var.env}-nsg"
  }
}

resource "azurerm_dns_a_record" "main" {
  name                = "${var.component}-${var.env}"
  zone_name           = "azdevops.online"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 10
  records             = [azurerm_network_interface.main.private_ip_address]
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}


resource "azurerm_virtual_machine" "main" {
  name                  = var.component
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B2s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "/subscriptions/00f9828e-4aad-42e5-ac92-a3c54883cbd3/resourceGroups/project-setup1/providers/Microsoft.Compute/galleries/customPractice/images/CustomImage/versions/1.0.0"
  }

    storage_os_disk {
      name              = "${var.component}-${var.env}"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    }
    os_profile {
      computer_name  = var.component
      admin_username = "testadmin"
      admin_password = "Password1234!"
    }
    os_profile_linux_config {
      disable_password_authentication = false
    }
    tags = {
      component = var.component
    }
  }