terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_sql_database_instance" "this" {
  name                = "${var.project}-${var.environment}-pgsql"
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = false

  settings {
    tier      = var.tier
    disk_size = var.disk_size

    ip_configuration {
      ipv4_enabled = true
    }

    user_labels = var.tags
  }
}

resource "google_sql_database" "this" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  password = var.db_password
}
