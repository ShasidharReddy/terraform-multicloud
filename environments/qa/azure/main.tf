terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Cloud       = "azure"
  }

  deploy_vms        = var.compute_type == "vm"
  deploy_kubernetes = var.use_kubernetes || var.compute_type == "kubernetes"
}

module "vnet" {
  source              = "../../../modules/azure/vnet"
  project             = var.project
  environment         = var.environment
  location            = var.location
  vnet_cidr           = var.vnet_cidr
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

module "bastion" {
  count               = var.create_bastion ? 1 : 0
  source              = "../../../modules/azure/bastion"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.vnet.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.public_subnet_id
  admin_username      = var.admin_username
  public_key          = var.bastion_public_key
  allowed_ssh_cidrs   = var.ssh_allowed_cidrs
  tags                = local.common_tags
}

module "compute" {
  count               = local.deploy_vms ? 1 : 0
  source              = "../../../modules/azure/compute"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.vnet.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.private_subnet_id
  vm_count            = var.vm_count
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  assign_public_ip    = var.assign_public_ip
  tags                = local.common_tags
}

module "database" {
  source              = "../../../modules/azure/database"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.vnet.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.db_subnet_id
  engine              = var.db_engine
  db_name             = var.db_name
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb
  postgresql_version  = var.postgresql_version
  mysql_version       = var.mysql_version
  mssql_sku           = var.mssql_sku
  tags                = local.common_tags
}

module "aks" {
  count               = local.deploy_kubernetes ? 1 : 0
  source              = "../../../modules/azure/aks"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.vnet.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.private_subnet_id
  kubernetes_version  = var.kubernetes_version
  node_vm_size        = var.node_vm_size
  node_count          = var.node_count
  node_min_count      = var.node_min_count
  node_max_count      = var.node_max_count
  node_disk_size      = var.node_disk_size
  enable_auto_scaling = var.enable_auto_scaling
  admin_username      = var.aks_admin_username
  public_key          = coalesce(var.kubernetes_public_key, var.bastion_public_key)
  tags                = local.common_tags
}

module "storage" {
  source              = "../../../modules/azure/storage"
  project             = var.project
  environment         = var.environment
  resource_group_name = module.vnet.resource_group_name
  location            = var.location
  account_tier        = var.account_tier
  replication_type    = var.replication_type
  tags                = local.common_tags
}
