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
  description = "Delegated subnet identifier for database resources when needed."
  type        = string
}

variable "engine" {
  description = "Database engine: postgresql, mysql, sqlserver"
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql", "sqlserver"], var.engine)
    error_message = "engine must be one of: postgresql, mysql, sqlserver"
  }
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "admin_username" {
  description = "Database administrator username."
  type        = string
}

variable "admin_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Azure database SKU name."
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

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
