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
  }
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

module "compute" {
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
  db_name             = var.db_name
  admin_username      = var.db_admin_username
  admin_password      = var.db_admin_password
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb
  postgresql_version  = var.postgresql_version
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
