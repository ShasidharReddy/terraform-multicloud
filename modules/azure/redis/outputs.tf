output "redis_hostname" {
  value = azurerm_redis_cache.this.hostname
}

output "redis_port" {
  value = azurerm_redis_cache.this.ssl_port
}

output "redis_primary_key" {
  value     = azurerm_redis_cache.this.primary_access_key
  sensitive = true
}

output "redis_connection_string" {
  value     = "${azurerm_redis_cache.this.hostname}:${azurerm_redis_cache.this.ssl_port},password=${azurerm_redis_cache.this.primary_access_key},ssl=True,abortConnect=False"
  sensitive = true
}
