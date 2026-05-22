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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*GA*HVM-20*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  name_prefix        = "${var.project}-${var.environment}"
  effective_key_name = var.key_name != null ? var.key_name : try(aws_key_pair.this[0].key_name, null)
  ami_map = {
    "ubuntu"       = data.aws_ami.ubuntu.id
    "rhel"         = data.aws_ami.rhel.id
    "amazon-linux" = data.aws_ami.amazon_linux.id
    "debian"       = data.aws_ami.debian.id
  }
  effective_ami = coalesce(var.ami_id, lookup(local.ami_map, lower(var.image_os), data.aws_ami.amazon_linux.id))
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

  ami                         = local.effective_ami
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids      = concat([aws_security_group.this.id], var.additional_security_group_ids)
  associate_public_ip_address = false
  key_name                    = local.effective_key_name

  tags = merge(local.instance_tags, {
    Name = "${local.name_prefix}-vm-${count.index + 1}"
  })
}
