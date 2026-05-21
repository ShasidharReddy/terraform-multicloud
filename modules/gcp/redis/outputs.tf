output "redis_host" {
  value = google_redis_instance.this.host
}

output "redis_port" {
  value = google_redis_instance.this.port
}

output "redis_auth_string" {
  value     = google_redis_instance.this.auth_string
  sensitive = true
}

output "redis_connection" {
  description = "Redis connection in host:port format."
  value       = "${google_redis_instance.this.host}:${google_redis_instance.this.port}"
}
