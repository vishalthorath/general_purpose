terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "task21-vm-nic"
  location            = "South India"
  resource_group_name = "VT-RG"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "task21-vnet"
  location            = "South India"
  resource_group_name = "VT-RG"
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "task21-subnet"
  resource_group_name  = "VT-RG"
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "task21-vm-public-ip"
  location            = "South India"
  resource_group_name = "VT-RG"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "task21-vm"
  resource_group_name = "VT-RG"
  location            = "South India"
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/azureuservishal/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
