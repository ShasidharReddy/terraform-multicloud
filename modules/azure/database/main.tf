terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  name_prefix      = lower(replace("${var.project}-${var.environment}", "_", "-"))
  server_name      = substr(replace("${local.name_prefix}-${random_string.suffix.result}", "-", ""), 0, 63)
  private_dns_name = "${local.name_prefix}.private.postgres.database.azure.com"
  vnet_id          = split("/subnets/", var.subnet_id)[0]
}

resource "azurerm_private_dns_zone" "this" {
  name                = local.private_dns_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${local.name_prefix}-pgsql-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = local.vnet_id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = local.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.this.id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  version                = var.postgresql_version
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  zone                   = "1"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
