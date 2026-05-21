variable "project_id" {
  description = "GCP project identifier."
  type        = string
}

variable "project" {
  description = "Project name prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "region" {
  description = "GCP region."
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
  description = "Cloud SQL database name."
  type        = string
}

variable "db_user" {
  description = "Cloud SQL user name."
  type        = string
}

variable "db_password" {
  description = "Cloud SQL user password."
  type        = string
  sensitive   = true
}

variable "tier" {
  description = "Cloud SQL machine tier."
  type        = string
  default     = "db-f1-micro"
}

variable "database_version" {
  description = "Optional Cloud SQL version override."
  type        = string
  default     = null
}

variable "disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number
  default     = 20
}

variable "private_network_id" {
  description = "Private VPC network self link for Cloud SQL private service access."
  type        = string
}

variable "tags" {
  description = "Cloud SQL labels."
  type        = map(string)
  default     = {}
}
