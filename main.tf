resource "azurerm_resource_group" "rg-1" { #Resource Group
  name     = "rg-1"
  location = "Centralindia"

}

resource "azurerm_virtual_network" "vnet-1" {
    #depends_on = [ azurerm_resource_group.rg-1 ]
  name                = "vnwt-1"
  location            = "Centralindia"
  resource_group_name = azurerm_resource_group.rg-1.name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "snet-1" {
   # depends_on = [ azurerm_resource_group.rg-1,azurerm_virtual_network.vnet-1 ]
  name                 = "snet-1"
  resource_group_name  = azurerm_resource_group.rg-1.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_public_ip" "pip-1" {
    #depends_on = [ azurerm_resource_group.rg-1 ]

  name                = "pip-1"
  location            = azurerm_resource_group.rg-1.location
  resource_group_name = azurerm_resource_group.rg-1.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg-1" {
  name                = "nsg-1"
  location            = azurerm_resource_group.rg-1.location
  resource_group_name = azurerm_resource_group.rg-1.name
}

resource "azurerm_network_interface" "nic-1" {
  name                = "nic-1"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  ip_configuration {
    name                          = "ip"
    subnet_id                     = azurerm_subnet.snet-1.id
    public_ip_address_id = azurerm_public_ip.pip-1.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_network_interface_security_group_association" "nsg_ass" {
  network_interface_id      = azurerm_network_interface.nic-1.id
  network_security_group_id = azurerm_network_security_group.nsg-1.id
}

resource "azurerm_virtual_machine" "vm-1" {

  #depends_on            = [azurerm_network_interface.nic-1]
  name                  = "vm-1"
  location              = azurerm_resource_group.rg-1.location
  resource_group_name   = azurerm_resource_group.rg-1.name
  network_interface_ids = [azurerm_network_interface.nic-1.id]
  vm_size               = "Standard_D2s_v3"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"

  }
  storage_os_disk {
    name              = "disk-01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "azureuser"
    admin_password = "azureuser@123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

}
