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
