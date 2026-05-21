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
  description = "Cloud SQL PostgreSQL version."
  type        = string
  default     = "POSTGRES_14"
}

variable "disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Cloud SQL labels."
  type        = map(string)
  default     = {}
}
