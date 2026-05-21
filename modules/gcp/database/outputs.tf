output "db_connection_name" {
  description = "Cloud SQL connection name."
  value       = google_sql_database_instance.this.connection_name
}

output "db_public_ip" {
  description = "Cloud SQL public IP address."
  value       = google_sql_database_instance.this.public_ip_address
}

output "db_name" {
  description = "Cloud SQL database name."
  value       = google_sql_database.this.name
}

output "db_user" {
  description = "Cloud SQL user."
  value       = google_sql_user.this.name
}
