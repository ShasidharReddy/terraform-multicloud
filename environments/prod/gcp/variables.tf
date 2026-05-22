variable "project" {
  description = "Project name."
  type        = string
  default     = "my-project"

}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"

}

variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = ""

}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-east1"

}

variable "zone" {
  description = "GCP zone."
  type        = string
  default     = "us-east1-b"

}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"

}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block."
  type        = string
  default     = "10.0.1.0/24"

}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block."
  type        = string
  default     = "10.0.2.0/24"

}

variable "db_subnet_cidr" {
  description = "DB subnet CIDR block."
  type        = string
  default     = "10.0.3.0/24"

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
  description = "Number of GCP VMs."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 50
    error_message = "vm_count must be between 1 and 50."
  }
}

variable "machine_type" {
  description = "GCP machine type."
  type        = string
  default     = "n2-standard-4"

}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 30
}

variable "image" {
  description = "Boot image."
  type        = string
  default     = ""
}

variable "image_os" {
  description = "Boot image OS selection."
  type        = string
  default     = "ubuntu"
}

variable "bastion_public_key" {
  description = "SSH public key used for bastion access."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Minimum GKE Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "node_machine_type" {
  description = "GKE node machine type."
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Desired GKE node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 50
    error_message = "node_count must be between 1 and 50."
  }
}

variable "node_min_count" {
  description = "Minimum GKE node count."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum GKE node count."
  type        = number
  default     = 10

  validation {
    condition     = var.node_max_count >= 1 && var.node_max_count <= 50
    error_message = "node_max_count must be between 1 and 50."
  }
}

variable "node_disk_size" {
  description = "GKE node disk size in GB."
  type        = number
  default     = 50
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "cluster_ipv4_cidr" {
  description = "CIDR block for GKE pods."
  type        = string
  default     = "172.20.0.0/16"
}

variable "services_ipv4_cidr" {
  description = "CIDR block for GKE services."
  type        = string
  default     = "172.21.0.0/22"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the private GKE control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "db_engine" {
  description = "GCP database engine selection."
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql", "sqlserver"], var.db_engine)
    error_message = "db_engine must be one of: postgresql, mysql, sqlserver."
  }
}

variable "db_name" {
  description = "Cloud SQL database name."
  type        = string
  default     = "appdb"

}

variable "db_user" {
  description = "Cloud SQL username."
  type        = string
  default     = "dbadmin"

}

variable "db_password" {
  description = "Cloud SQL password."
  type        = string
  default     = "TfDefault2024!"
  sensitive   = true
}

variable "db_tier" {
  description = "Cloud SQL tier."
  type        = string
  default     = "db-f1-micro"
}

variable "database_version" {
  description = "Optional Cloud SQL version override."
  type        = string
  default     = null
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number
  default     = 20
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB."
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "GCP Redis version string."
  type        = string
  default     = "REDIS_7_0"
}

variable "bucket_name_suffix" {
  description = "Suffix for the GCS bucket name."
  type        = string
  default     = "data"

}

variable "storage_class" {
  description = "GCS storage class."
  type        = string
  default     = "STANDARD"
}
