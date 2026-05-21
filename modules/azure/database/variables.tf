variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Delegated subnet identifier for PostgreSQL Flexible Server."
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
}

variable "admin_username" {
  description = "PostgreSQL administrator username."
  type        = string
}

variable "admin_password" {
  description = "PostgreSQL administrator password."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Azure PostgreSQL SKU name."
  type        = string
}

variable "storage_mb" {
  description = "Allocated storage in MB."
  type        = number
  default     = 32768
}

variable "postgresql_version" {
  description = "PostgreSQL version."
  type        = string
  default     = "14"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
