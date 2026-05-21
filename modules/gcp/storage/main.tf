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

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  bucket_name = lower(join("-", [var.project, var.environment, var.bucket_name_suffix, random_string.suffix.result]))
}

resource "google_storage_bucket" "this" {
  name                        = local.bucket_name
  project                     = var.project_id
  location                    = var.region
  storage_class               = var.storage_class
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.tags
}

resource "google_storage_bucket_iam_binding" "this" {
  bucket  = google_storage_bucket.this.name
  role    = "roles/storage.objectViewer"
  members = ["projectViewer:${var.project_id}"]
}
