terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

locals {
  region         = join("-", slice(split("-", var.zone), 0, length(split("-", var.zone)) - 1))
  ssh_user       = "debian"
  ssh_public_key = "${local.ssh_user}:${trimspace(var.public_key)}"
}

data "google_compute_subnetwork" "public" {
  name    = "${var.project}-${var.environment}-public"
  project = var.project_id
  region  = local.region
}

resource "google_compute_firewall" "bastion_ssh" {
  name    = "${var.project}-${var.environment}-bastion-ssh"
  project = var.project_id
  network = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["bastion"]
}

resource "google_compute_instance" "bastion" {
  name         = "${var.project}-${var.environment}-bastion"
  machine_type = "f1-micro"
  zone         = var.zone
  project      = var.project_id
  tags         = ["bastion"]
  labels       = var.tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-balanced"
    }
  }

  metadata = {
    ssh-keys = local.ssh_public_key
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = data.google_compute_subnetwork.public.self_link

    access_config {}
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
