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
  is_postgresql = var.engine == "postgresql"
  is_mysql      = var.engine == "mysql"
  is_mssql      = var.engine == "sqlserver"
  name_prefix   = lower(replace("${var.project}-${var.environment}", "_", "-"))
}

resource "azurerm_postgresql_flexible_server" "this" {
  count                  = local.is_postgresql ? 1 : 0
  name                   = substr(replace("${local.name_prefix}-psql-${random_string.suffix.result}", "-", ""), 0, 63)
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  backup_retention_days  = var.environment == "prod" ? 14 : 7
  tags                   = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  count     = local.is_postgresql ? 1 : 0
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this[0].id
}

resource "azurerm_mysql_flexible_server" "this" {
  count                  = local.is_mysql ? 1 : 0
  name                   = substr(replace("${local.name_prefix}-mysql-${random_string.suffix.result}", "-", ""), 0, 63)
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku_name               = var.sku_name
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  version                = var.mysql_version
  backup_retention_days  = var.environment == "prod" ? 14 : 7
  tags                   = var.tags
}

resource "azurerm_mysql_flexible_database" "this" {
  count               = local.is_mysql ? 1 : 0
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this[0].name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mssql_server" "this" {
  count                        = local.is_mssql ? 1 : 0
  name                         = substr(replace("${local.name_prefix}-mssql-${random_string.suffix.result}", "-", ""), 0, 63)
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  tags                         = var.tags
}

resource "azurerm_mssql_database" "this" {
  count     = local.is_mssql ? 1 : 0
  name      = var.db_name
  server_id = azurerm_mssql_server.this[0].id
  sku_name  = var.mssql_sku
  tags      = var.tags
}
