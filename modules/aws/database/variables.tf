variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier."
  type        = string
}

variable "db_subnet_ids" {
  description = "Database subnet identifiers."
  type        = list(string)
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Database administrator username."
  type        = string
}

variable "db_password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "14.9"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach PostgreSQL."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
