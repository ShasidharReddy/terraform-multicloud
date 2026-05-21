terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

locals {
  engine_map = {
    postgresql = "POSTGRES_14"
    mysql      = "MYSQL_8_0"
    sqlserver  = "SQLSERVER_2019_STANDARD"
  }
  db_version = var.database_version != null ? var.database_version : local.engine_map[var.engine]
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "this" {
  name             = "${var.project}-${var.environment}-sql-${random_id.suffix.hex}"
  database_version = local.db_version
  region           = var.region
  project          = var.project_id

  settings {
    tier            = var.tier
    disk_size       = var.disk_size
    disk_autoresize = true

    backup_configuration {
      enabled                        = true
      binary_log_enabled             = var.engine == "mysql"
      point_in_time_recovery_enabled = var.engine == "postgresql"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_id
    }

    user_labels = var.tags
  }

  deletion_protection = var.environment == "prod"
}

resource "google_sql_database" "this" {
  count    = var.engine != "sqlserver" ? 1 : 0
  name     = var.db_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}

resource "google_sql_user" "this" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  password = var.db_password
  project  = var.project_id
}
