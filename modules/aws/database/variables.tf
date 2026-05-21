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

variable "engine" {
  description = "Database engine: postgresql, mysql, sqlserver-se, aurora-postgresql, aurora-mysql"
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "mysql", "sqlserver-se", "aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be one of: postgresql, mysql, sqlserver-se, aurora-postgresql, aurora-mysql"
  }
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
  description = "Optional database engine version override."
  type        = string
  default     = null
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

variable "db_security_group_id" {
  description = "Security group ID for the database."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
