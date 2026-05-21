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
    cloud       = "gcp"
  }

  deploy_vms        = var.compute_type == "vm"
  deploy_kubernetes = var.use_kubernetes || var.compute_type == "kubernetes"
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

module "bastion" {
  count             = var.create_bastion ? 1 : 0
  source            = "../../../modules/gcp/bastion"
  project_id        = var.project_id
  project           = var.project
  environment       = var.environment
  zone              = var.zone
  network_self_link = module.vpc.network_self_link
  public_key        = var.bastion_public_key
  allowed_ssh_cidrs = var.ssh_allowed_cidrs
  tags              = local.common_tags
}

module "compute" {
  count             = local.deploy_vms ? 1 : 0
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

module "gke" {
  count                  = local.deploy_kubernetes ? 1 : 0
  source                 = "../../../modules/gcp/gke"
  project_id             = var.project_id
  project                = var.project
  environment            = var.environment
  region                 = var.region
  network_self_link      = module.vpc.network_self_link
  subnetwork_self_link   = module.vpc.private_subnet_self_link
  kubernetes_version     = var.kubernetes_version
  machine_type           = var.node_machine_type
  node_count             = var.node_count
  node_min_count         = var.node_min_count
  node_max_count         = var.node_max_count
  node_disk_size         = var.node_disk_size
  release_channel        = var.release_channel
  cluster_ipv4_cidr      = var.cluster_ipv4_cidr
  services_ipv4_cidr     = var.services_ipv4_cidr
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  tags                   = local.common_tags
}

module "database" {
  count              = var.enable_database ? 1 : 0
  source             = "../../../modules/gcp/database"
  project_id         = var.project_id
  project            = var.project
  environment        = var.environment
  region             = var.region
  engine             = var.db_engine
  db_name            = var.db_name
  db_user            = var.db_user
  db_password        = var.db_password
  tier               = var.db_tier
  database_version   = var.database_version
  disk_size          = var.db_disk_size
  private_network_id = module.vpc.network_self_link
  tags               = local.common_tags
}

module "redis" {
  count             = var.enable_redis ? 1 : 0
  source            = "../../../modules/gcp/redis"
  project_id        = var.project_id
  project           = var.project
  environment       = var.environment
  region            = var.region
  zone              = var.zone
  network_self_link = module.vpc.network_self_link
  memory_size_gb    = var.redis_memory_size_gb
  redis_version     = var.redis_version
  tags              = local.common_tags
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
