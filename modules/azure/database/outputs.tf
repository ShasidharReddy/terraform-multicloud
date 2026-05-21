locals {
  db_fqdn_value = (
    local.is_postgresql ? azurerm_postgresql_flexible_server.this[0].fqdn :
    local.is_mysql ? azurerm_mysql_flexible_server.this[0].fqdn :
    azurerm_mssql_server.this[0].fully_qualified_domain_name
  )
}

output "db_fqdn" {
  value = local.db_fqdn_value
}

output "db_name" {
  value = var.db_name
}

output "engine" {
  value = var.engine
}
