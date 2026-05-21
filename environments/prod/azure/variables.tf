variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
}

variable "vnet_cidr" {
  description = "VNet CIDR block."
  type        = string
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
  description = "Number of Azure VMs."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 50
    error_message = "vm_count must be between 1 and 50."
  }
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
}

variable "admin_username" {
  description = "VM administrator username."
  type        = string
}

variable "admin_password" {
  description = "VM administrator password."
  type        = string
  sensitive   = true
}

variable "assign_public_ip" {
  description = "Assign public IPs to Azure VMs."
  type        = bool
  default     = false
}

variable "bastion_public_key" {
  description = "SSH public key used for bastion access."
  type        = string
  default     = null
}

variable "kubernetes_public_key" {
  description = "SSH public key used for AKS node access."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = "1.29.0"
}

variable "node_vm_size" {
  description = "AKS node VM size."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "Desired AKS node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 50
    error_message = "node_count must be between 1 and 50."
  }
}

variable "node_min_count" {
  description = "Minimum AKS node count."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum AKS node count."
  type        = number
  default     = 10

  validation {
    condition     = var.node_max_count >= 1 && var.node_max_count <= 50
    error_message = "node_max_count must be between 1 and 50."
  }
}

variable "node_disk_size" {
  description = "AKS node disk size in GB."
  type        = number
  default     = 50
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling for AKS nodes."
  type        = bool
  default     = true
}

variable "aks_admin_username" {
  description = "AKS Linux admin username."
  type        = string
  default     = "azureuser"
}

variable "db_engine" {
  description = "Azure database engine selection."
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql", "sqlserver"], var.db_engine)
    error_message = "db_engine must be one of: postgresql, mysql, sqlserver."
  }
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_admin_username" {
  description = "Database administrator username."
  type        = string
}

variable "db_admin_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Azure database SKU name."
  type        = string
}

variable "storage_mb" {
  description = "Database storage in MB."
  type        = number
  default     = 32768
}

variable "postgresql_version" {
  description = "PostgreSQL version."
  type        = string
  default     = "14"
}

variable "mysql_version" {
  description = "MySQL Flexible Server version."
  type        = string
  default     = "8.0.21"
}

variable "mssql_sku" {
  description = "Azure SQL Database SKU name."
  type        = string
  default     = "Basic"
}

variable "account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage replication type."
  type        = string
  default     = "LRS"
}
