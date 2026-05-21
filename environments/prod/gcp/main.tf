terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  common_tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "vpc" {
  source              = "../../../modules/gcp/vpc"
  project_id          = var.project_id
  project             = var.project
  environment         = var.environment
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  db_subnet_cidr      = var.db_subnet_cidr
  tags                = local.common_tags
}

module "compute" {
  source            = "../../../modules/gcp/compute"
  project_id        = var.project_id
  project           = var.project
  environment       = var.environment
  region            = var.region
  zone              = var.zone
  network_self_link = module.vpc.network_self_link
  subnetwork_id     = module.vpc.private_subnet_id
  vm_count          = var.vm_count
  machine_type      = var.machine_type
  disk_size_gb      = var.disk_size_gb
  image             = var.image
  tags              = local.common_tags
}

module "database" {
  source           = "../../../modules/gcp/database"
  project_id       = var.project_id
  project          = var.project
  environment      = var.environment
  region           = var.region
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = var.db_password
  tier             = var.db_tier
  database_version = var.database_version
  disk_size        = var.db_disk_size
  tags             = local.common_tags
}

module "storage" {
  source             = "../../../modules/gcp/storage"
  project_id         = var.project_id
  project            = var.project
  environment        = var.environment
  region             = var.region
  bucket_name_suffix = var.bucket_name_suffix
  storage_class      = var.storage_class
  tags               = local.common_tags
}
