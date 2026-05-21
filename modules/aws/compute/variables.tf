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

variable "private_subnet_ids" {
  description = "Private subnet identifiers."
  type        = list(string)
}

variable "vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 50
    error_message = "vm_count must be between 1 and 50."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "ami_id" {
  description = "Optional AMI ID override."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional existing key pair name."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Optional public key content used when creating a key pair."
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Additional security group identifiers to attach to compute instances."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
