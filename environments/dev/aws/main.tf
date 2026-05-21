terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source      = "../../../modules/aws/vpc"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  region      = var.region
  tags        = local.common_tags
}

module "compute" {
  source             = "../../../modules/aws/compute"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vm_count           = var.vm_count
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  key_name           = var.key_name
  public_key         = var.public_key
  tags               = local.common_tags
}

module "database" {
  source            = "../../../modules/aws/database"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_subnet_ids     = module.vpc.db_subnet_ids
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  instance_class    = var.db_instance_class
  engine_version    = var.db_engine_version
  allocated_storage = var.allocated_storage
  multi_az          = var.multi_az
  tags              = local.common_tags
}

module "storage" {
  source             = "../../../modules/aws/storage"
  project            = var.project
  environment        = var.environment
  bucket_name_suffix = var.bucket_name_suffix
  tags               = local.common_tags
}
