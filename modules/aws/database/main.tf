terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  is_aurora = contains(["aurora-postgresql", "aurora-mysql"], var.engine)
  is_mssql  = contains(["sqlserver-se", "sqlserver-ex"], var.engine)
  engine_map = {
    postgresql = {
      engine = "postgres"
      port   = 5432
      family = "postgres14"
      major  = "14"
    }
    mysql = {
      engine = "mysql"
      port   = 3306
      family = "mysql8.0"
      major  = "8.0"
    }
    sqlserver-se = {
      engine = "sqlserver-se"
      port   = 1433
      family = "sqlserver-se-15.0"
      major  = "15.00"
    }
    aurora-postgresql = {
      engine = "aurora-postgresql"
      port   = 5432
      family = "aurora-postgresql14"
      major  = "14"
    }
    aurora-mysql = {
      engine = "aurora-mysql"
      port   = 3306
      family = "aurora-mysql8.0"
      major  = "8.0"
    }
  }
  cfg = local.engine_map[var.engine]
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "this" {
  count  = local.is_aurora ? 0 : 1
  name   = "${var.project}-${var.environment}-pg"
  family = local.cfg.family
  tags   = var.tags
}

resource "aws_db_instance" "this" {
  count                      = local.is_aurora ? 0 : 1
  identifier                 = "${var.project}-${var.environment}-db"
  engine                     = local.cfg.engine
  engine_version             = var.engine_version != null ? var.engine_version : local.cfg.major
  instance_class             = var.instance_class
  allocated_storage          = local.is_mssql ? max(var.allocated_storage, 20) : var.allocated_storage
  storage_encrypted          = true
  db_name                    = local.is_mssql ? null : var.db_name
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [var.db_security_group_id]
  parameter_group_name       = aws_db_parameter_group.this[0].name
  multi_az                   = var.multi_az
  skip_final_snapshot        = var.environment != "prod"
  backup_retention_period    = var.environment == "prod" ? 7 : 1
  license_model              = local.is_mssql ? "license-included" : null
  publicly_accessible        = false
  deletion_protection        = var.environment == "prod"
  apply_immediately          = true
  auto_minor_version_upgrade = true

  tags = merge(var.tags, {
    Name   = "${var.project}-${var.environment}-db"
    Engine = var.engine
  })
}

resource "aws_rds_cluster" "aurora" {
  count                   = local.is_aurora ? 1 : 0
  cluster_identifier      = "${var.project}-${var.environment}-aurora"
  engine                  = local.cfg.engine
  engine_version          = var.engine_version != null ? var.engine_version : local.cfg.major
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.db_security_group_id]
  skip_final_snapshot     = var.environment != "prod"
  backup_retention_period = var.environment == "prod" ? 7 : 1
  storage_encrypted       = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-aurora"
  })
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = local.is_aurora ? (var.environment == "prod" ? 2 : 1) : 0
  identifier         = "${var.project}-${var.environment}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = local.cfg.engine
  engine_version     = var.engine_version != null ? var.engine_version : local.cfg.major
  tags               = var.tags
}
