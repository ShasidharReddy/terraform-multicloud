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

variable "vm_count" {
  description = "Number of Azure VMs."
  type        = number

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10."
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

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "db_admin_username" {
  description = "PostgreSQL administrator username."
  type        = string
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "PostgreSQL SKU name."
  type        = string
}

variable "storage_mb" {
  description = "PostgreSQL storage in MB."
  type        = number
  default     = 32768
}

variable "postgresql_version" {
  description = "PostgreSQL version."
  type        = string
  default     = "14"
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

variable "assign_public_ip" {
  description = "Assign public IPs to Azure VMs."
  type        = bool
  default     = false
}
