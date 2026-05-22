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
  instance_tags = ["ssh", "${var.project}-${var.environment}"]
  image_map = {
    ubuntu = "ubuntu-os-cloud/ubuntu-2204-lts"
    rhel   = "rhel-cloud/rhel-8"
    debian = "debian-cloud/debian-11"
    rocky  = "rocky-linux-cloud/rocky-linux-9"
    centos = "centos-cloud/centos-stream-9"
  }
  effective_image = coalesce(var.image, lookup(local.image_map, lower(var.image_os), "ubuntu-os-cloud/ubuntu-2204-lts"))
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.project}-${var.environment}-compute-ssh"
  project = var.project_id
  network = var.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.instance_tags
}

resource "google_compute_instance" "this" {
  count        = var.vm_count
  project      = var.project_id
  zone         = var.zone
  name         = "${var.project}-${var.environment}-vm-${count.index + 1}"
  machine_type = var.machine_type
  tags         = local.instance_tags
  labels       = var.tags

  boot_disk {
    initialize_params {
      image = local.effective_image
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnetwork_id
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
