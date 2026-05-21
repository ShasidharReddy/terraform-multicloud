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
  description = "Public subnet identifier for the bastion host."
  type        = string
}

variable "admin_username" {
  description = "Administrator username for the bastion host."
  type        = string
}

variable "public_key" {
  description = "SSH public key for bastion access."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to the bastion host."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
