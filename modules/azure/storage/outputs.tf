output "storage_account_id" {
  description = "Azure Storage Account identifier."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Azure Storage Account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_name" {
  description = "Blob container name."
  value       = azurerm_storage_container.this.name
}
