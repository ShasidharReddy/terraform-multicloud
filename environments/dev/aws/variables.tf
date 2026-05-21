variable "project" {
  description = "Project name."
  type        = string
  default     = "my-project"

}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"

}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"

}

variable "use_kubernetes" {
  description = "Deploy Kubernetes resources in addition to compute_type selection."
  type        = bool
  default     = false
}

variable "compute_type" {
  description = "Primary compute type to deploy."
  type        = string
  default     = "vm"

  validation {
    condition     = contains(["vm", "kubernetes"], var.compute_type)
    error_message = "compute_type must be either vm or kubernetes."
  }
}

variable "enable_database" {
  description = "Deploy database resources. Set to false to skip database deployment."
  type        = bool
  default     = true
}

variable "enable_redis" {
  description = "Deploy Redis cache resources."
  type        = bool
  default     = false
}

variable "create_bastion" {
  description = "Create a bastion host for SSH access."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH to bastion resources."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vm_count" {
  description = "Number of AWS VMs."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 50
    error_message = "vm_count must be between 1 and 50."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"

}

variable "ami_id" {
  description = "Optional AMI override."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "vm_public_key" {
  description = "Optional public key material used to create VM SSH access."
  type        = string
  default     = null
}

variable "bastion_public_key" {
  description = "SSH public key used for bastion access."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EKS node instance type."
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Desired EKS node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 50
    error_message = "node_count must be between 1 and 50."
  }
}

variable "node_min_count" {
  description = "Minimum EKS node count."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum EKS node count."
  type        = number
  default     = 10

  validation {
    condition     = var.node_max_count >= 1 && var.node_max_count <= 50
    error_message = "node_max_count must be between 1 and 50."
  }
}

variable "node_disk_size" {
  description = "EKS node disk size in GB."
  type        = number
  default     = 50
}

variable "public_api_access" {
  description = "Expose the EKS API publicly."
  type        = bool
  default     = true
}

variable "api_allowed_cidrs" {
  description = "Allowed CIDRs for the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.0"
}

variable "db_name" {
  description = "RDS database name."
  type        = string
  default     = "appdb"

}

variable "db_username" {
  description = "RDS admin username."
  type        = string
  default     = "dbadmin"

}

variable "db_password" {
  description = "RDS admin password."
  type        = string
  default     = "TfDefault2024!"
  sensitive   = true
}

variable "db_engine" {
  description = "AWS database engine selection."
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql", "sqlserver-se", "aurora-postgresql", "aurora-mysql"], var.db_engine)
    error_message = "db_engine must be one of: postgresql, mysql, sqlserver-se, aurora-postgresql, aurora-mysql."
  }
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"

}

variable "db_engine_version" {
  description = "Optional RDS engine version override."
  type        = string
  default     = null
}

variable "allocated_storage" {
  description = "RDS storage in GB."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ RDS."
  type        = bool
  default     = false

}

variable "bucket_name_suffix" {
  description = "Suffix for the S3 bucket name."
  type        = string
  default     = "data"

}
