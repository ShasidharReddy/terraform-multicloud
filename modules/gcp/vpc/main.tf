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
  network_name = "${var.project}-${var.environment}-vpc"
}

resource "google_compute_network" "this" {
  name                    = local.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public" {
  name          = "${var.project}-${var.environment}-public"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
  project       = var.project_id
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.project}-${var.environment}-private"
  ip_cidr_range            = var.private_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.this.id
  project                  = var.project_id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name                     = "${var.project}-${var.environment}-db"
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.this.id
  project                  = var.project_id
  private_ip_google_access = true
}

resource "google_compute_router" "this" {
  name    = "${var.project}-${var.environment}-router"
  network = google_compute_network.this.id
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.project}-${var.environment}-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_route" "default_internet" {
  name             = "${var.project}-${var.environment}-default-internet"
  project          = var.project_id
  network          = google_compute_network.this.name
  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_firewall" "internal" {
  name    = "${var.project}-${var.environment}-allow-internal"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.project}-${var.environment}-allow-ssh"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name    = "${var.project}-${var.environment}-allow-http"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https" {
  name    = "${var.project}-${var.environment}-allow-https"
  network = google_compute_network.this.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
