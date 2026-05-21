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

variable "zone" {
  description = "GCP zone for the bastion host."
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link."
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
  description = "GCP labels."
  type        = map(string)
  default     = {}
}
