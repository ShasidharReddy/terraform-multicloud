terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

resource "google_redis_instance" "this" {
  name                    = "${var.project}-${var.environment}-redis"
  display_name            = "${var.project} ${var.environment} Redis"
  tier                    = var.environment == "prod" ? "STANDARD_HA" : "BASIC"
  memory_size_gb          = var.memory_size_gb
  region                  = var.region
  location_id             = var.zone != "" ? var.zone : null
  redis_version           = var.redis_version
  authorized_network      = var.network_self_link
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  project                 = var.project_id

  redis_configs = {
    maxmemory-policy = var.maxmemory_policy
  }

  labels = var.tags
}
