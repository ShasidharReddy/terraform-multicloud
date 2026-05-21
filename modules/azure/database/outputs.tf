output "db_fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "db_name" {
  description = "Database name."
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "db_id" {
  description = "Database server identifier."
  value       = azurerm_postgresql_flexible_server.this.id
}
