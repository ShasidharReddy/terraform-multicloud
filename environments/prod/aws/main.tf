terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Cloud       = "aws"
  }

  deploy_vms        = var.compute_type == "vm"
  deploy_kubernetes = var.use_kubernetes || var.compute_type == "kubernetes"
}

module "vpc" {
  source      = "../../../modules/aws/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  tags        = local.common_tags
}

module "bastion" {
  count             = var.create_bastion ? 1 : 0
  source            = "../../../modules/aws/bastion"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  public_key        = var.bastion_public_key
  allowed_ssh_cidrs = var.ssh_allowed_cidrs
  ami_id            = var.ami_id
  tags              = local.common_tags
}

module "security_groups" {
  source        = "../../../modules/aws/security-groups"
  project       = var.project
  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  bastion_sg_id = var.create_bastion ? module.bastion[0].bastion_security_group_id : ""
  tags          = local.common_tags
}

module "compute" {
  count                         = local.deploy_vms ? 1 : 0
  source                        = "../../../modules/aws/compute"
  project                       = var.project
  environment                   = var.environment
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  vm_count                      = var.vm_count
  instance_type                 = var.instance_type
  ami_id                        = var.ami_id
  image_os                      = var.image_os
  key_name                      = var.key_name
  public_key                    = var.vm_public_key
  additional_security_group_ids = [module.security_groups.app_sg_id]
  tags                          = local.common_tags
}

module "eks" {
  count                         = local.deploy_kubernetes ? 1 : 0
  source                        = "../../../modules/aws/eks"
  project                       = var.project
  environment                   = var.environment
  private_subnet_ids            = module.vpc.private_subnet_ids
  public_subnet_ids             = module.vpc.public_subnet_ids
  kubernetes_version            = var.kubernetes_version
  node_instance_type            = var.node_instance_type
  node_count                    = var.node_count
  node_min_count                = var.node_min_count
  node_max_count                = var.node_max_count
  node_disk_size                = var.node_disk_size
  public_api_access             = var.public_api_access
  api_allowed_cidrs             = var.api_allowed_cidrs
  additional_security_group_ids = [module.security_groups.eks_workers_sg_id]
  tags                          = local.common_tags
}

module "database" {
  count                = var.enable_database ? 1 : 0
  source               = "../../../modules/aws/database"
  project              = var.project
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  db_subnet_ids        = module.vpc.db_subnet_ids
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  instance_class       = var.db_instance_class
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  allocated_storage    = var.allocated_storage
  multi_az             = var.multi_az
  db_security_group_id = module.security_groups.db_sg_id
  tags                 = local.common_tags
}

module "redis" {
  count               = var.enable_redis ? 1 : 0
  source              = "../../../modules/aws/redis"
  project             = var.project
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_type           = var.redis_node_type
  engine_version      = var.redis_engine_version
  allowed_cidr_blocks = [var.vpc_cidr]
  tags                = local.common_tags
}

module "storage" {
  source             = "../../../modules/aws/storage"
  project            = var.project
  environment        = var.environment
  bucket_name_suffix = var.bucket_name_suffix
  tags               = local.common_tags
}
