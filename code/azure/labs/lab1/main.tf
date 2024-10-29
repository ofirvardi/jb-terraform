provider "azurerm" {
  features {}
}

variable "my_name" {
  type    = string
  default = "ofirv"
}

variable "location" {
  default = "East US"
}

resource "azurerm_resource_group" "rg-ofirv" {
  name     = "${var.my_name}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-ofirv" {
  name                = "${var.my_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ofirv.name
}

resource "azurerm_subnet" "subnet-ofirv" {
  name                 = "${var.my_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg-ofirv.name
  virtual_network_name = azurerm_virtual_network.vnet-ofirv.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-ofirv" {
  name                = "${var.my_name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ofirv.name
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}

resource "azurerm_network_interface" "nic-ofirv" {
  name                = "${var.my_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ofirv.name

  ip_configuration {
    name                          = "${var.my_name}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-ofirv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-ofirv.id
  }
}

variable "vm_size" {
  default = "Standard_B1ms"
}

variable "admin_username" {
  default = "adminuser-ofirv"
}

variable "admin_password" {
  default = "Password123!"
}

resource "azurerm_linux_virtual_machine" "vm-ofirv" {
  name                  = "${var.my_name}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-ofirv.name
  network_interface_ids = [azurerm_network_interface.nic-ofirv.id]
  size                  = var.vm_size

  os_disk {
    name              = "${var.my_name}-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "${var.my_name}-vm"
}

output "vm_public_ip" {
  value = azurerm_public_ip.pip-ofirv.ip_address
  description = "Public IP address of the VM"
}

