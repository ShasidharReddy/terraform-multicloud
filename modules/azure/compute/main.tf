terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  image_map = {
    ubuntu = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
    rhel = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "9-gen2"
      version   = "latest"
    }
    debian = {
      publisher = "Debian"
      offer     = "debian-11"
      sku       = "11-gen2"
      version   = "latest"
    }
    windows = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      version   = "latest"
    }
  }
  effective_image = lookup(local.image_map, lower(var.image_os), local.image_map["ubuntu"])
  is_windows      = lower(var.image_os) == "windows"
}

resource "azurerm_public_ip" "this" {
  count = var.assign_public_ip ? var.vm_count : 0

  name                = "${local.name_prefix}-pip-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  count = var.vm_count

  name                = "${local.name_prefix}-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.this[count.index].id : null
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_windows ? 0 : var.vm_count

  name                            = "${local.name_prefix}-vm-${count.index + 1}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.this[count.index].id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = local.effective_image.publisher
    offer     = local.effective_image.offer
    sku       = local.effective_image.sku
    version   = local.effective_image.version
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? var.vm_count : 0

  name                  = "${local.name_prefix}-vm-${count.index + 1}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = local.effective_image.publisher
    offer     = local.effective_image.offer
    sku       = local.effective_image.sku
    version   = local.effective_image.version
  }

  tags = var.tags
}
