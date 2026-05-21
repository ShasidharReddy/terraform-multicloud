output "instance_names" {
  description = "GCP instance names."
  value       = google_compute_instance.this[*].name
}

output "instance_ids" {
  description = "GCP instance identifiers."
  value       = google_compute_instance.this[*].instance_id
}

output "self_links" {
  description = "GCP instance self links."
  value       = google_compute_instance.this[*].self_link
}

output "private_ips" {
  description = "Private IP addresses of the GCP instances."
  value       = google_compute_instance.this[*].network_interface[0].network_ip
}

output "zones" {
  description = "Zones where the instances are deployed."
  value       = google_compute_instance.this[*].zone
}
