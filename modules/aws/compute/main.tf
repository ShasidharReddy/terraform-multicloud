terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  name_prefix        = "${var.project}-${var.environment}"
  effective_key_name = var.key_name != null ? var.key_name : try(aws_key_pair.this[0].key_name, null)
  instance_tags = merge(var.tags, {
    Role = "compute"
  })
}

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-compute-sg"
  description = "Security group for ${local.name_prefix} compute instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-compute-sg"
  })
}

resource "aws_key_pair" "this" {
  count = var.key_name != null && var.public_key != null ? 1 : 0

  key_name   = var.key_name
  public_key = var.public_key

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-keypair"
  })
}

resource "aws_instance" "this" {
  count = var.vm_count

  ami                         = coalesce(var.ami_id, data.aws_ami.amazon_linux.id)
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids      = concat([aws_security_group.this.id], var.additional_security_group_ids)
  associate_public_ip_address = false
  key_name                    = local.effective_key_name

  tags = merge(local.instance_tags, {
    Name = "${local.name_prefix}-vm-${count.index + 1}"
  })
}
