variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet identifiers for worker nodes."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet identifiers for control plane access and load balancers."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EKS node instance type."
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Desired node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 50
    error_message = "node_count must be between 1 and 50."
  }
}

variable "node_min_count" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum node count."
  type        = number
  default     = 10

  validation {
    condition     = var.node_max_count >= 1 && var.node_max_count <= 50
    error_message = "node_max_count must be between 1 and 50."
  }
}

variable "node_disk_size" {
  description = "Worker node disk size in GB."
  type        = number
  default     = 50
}

variable "public_api_access" {
  description = "Expose the EKS API publicly."
  type        = bool
  default     = true
}

variable "api_allowed_cidrs" {
  description = "Allowed CIDRs for public EKS API access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_security_group_ids" {
  description = "Additional cluster security groups."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
