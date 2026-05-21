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

variable "vpc_cidr" {
  description = "VPC CIDR range."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR range."
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR range."
  type        = string
}

variable "db_subnet_cidr" {
  description = "Database subnet CIDR range."
  type        = string
}

variable "tags" {
  description = "Labels applied to GCP resources."
  type        = map(string)
  default     = {}
}
