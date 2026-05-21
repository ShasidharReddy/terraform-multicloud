output "db_connection_name" {
  description = "Cloud SQL connection name."
  value       = google_sql_database_instance.this.connection_name
}

output "db_private_ip" {
  description = "Cloud SQL private IP address."
  value       = google_sql_database_instance.this.private_ip_address
}

output "db_name" {
  description = "Cloud SQL database name."
  value       = var.db_name
}

output "engine" {
  description = "Configured Cloud SQL engine."
  value       = var.engine
}
