output "resource_group_name" {
  description = "Azure resource group name."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "Virtual network identifier."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.this.name
}

output "public_subnet_id" {
  description = "Public subnet identifier."
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet identifier."
  value       = azurerm_subnet.private.id
}

output "db_subnet_id" {
  description = "Database subnet identifier."
  value       = azurerm_subnet.db.id
}
