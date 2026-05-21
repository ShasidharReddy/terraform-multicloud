variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "zone" {
  description = "GCP zone."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block."
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block."
  type        = string
}

variable "db_subnet_cidr" {
  description = "DB subnet CIDR block."
  type        = string
}

variable "vm_count" {
  description = "Number of GCP VMs."
  type        = number

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10."
  }
}

variable "machine_type" {
  description = "GCP machine type."
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 30
}

variable "image" {
  description = "Boot image."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "db_name" {
  description = "Cloud SQL database name."
  type        = string
}

variable "db_user" {
  description = "Cloud SQL username."
  type        = string
}

variable "db_password" {
  description = "Cloud SQL password."
  type        = string
  sensitive   = true
}

variable "db_tier" {
  description = "Cloud SQL tier."
  type        = string
  default     = "db-f1-micro"
}

variable "database_version" {
  description = "Cloud SQL database version."
  type        = string
  default     = "POSTGRES_14"
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB."
  type        = number
  default     = 20
}

variable "bucket_name_suffix" {
  description = "Suffix for the GCS bucket name."
  type        = string
}

variable "storage_class" {
  description = "GCS storage class."
  type        = string
  default     = "STANDARD"
}
