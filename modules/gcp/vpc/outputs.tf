output "network_id" {
  description = "VPC network identifier."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.this.name
}

output "public_subnet_id" {
  description = "Public subnetwork identifier."
  value       = google_compute_subnetwork.public.id
}

output "private_subnet_id" {
  description = "Private subnetwork identifier."
  value       = google_compute_subnetwork.private.id
}

output "private_subnet_self_link" {
  description = "Private subnetwork self link (for GKE)."
  value       = google_compute_subnetwork.private.self_link
}

output "db_subnet_id" {
  description = "Database subnetwork identifier."
  value       = google_compute_subnetwork.db.id
}

output "network_self_link" {
  description = "VPC self link."
  value       = google_compute_network.this.self_link
}
