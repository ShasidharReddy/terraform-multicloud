variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "vm_count" {
  description = "Number of AWS VMs."
  type        = number

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ami_id" {
  description = "Optional AMI override."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Optional public key material used to create a key pair."
  type        = string
  default     = null
}

variable "db_name" {
  description = "RDS database name."
  type        = string
}

variable "db_username" {
  description = "RDS admin username."
  type        = string
}

variable "db_password" {
  description = "RDS admin password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_engine_version" {
  description = "RDS engine version."
  type        = string
  default     = "14.9"
}

variable "allocated_storage" {
  description = "RDS storage in GB."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ RDS."
  type        = bool
}

variable "bucket_name_suffix" {
  description = "Suffix for the S3 bucket name."
  type        = string
}
