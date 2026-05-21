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
  description = "Subnet identifier used for AKS nodes."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = "1.29.0"
}

variable "node_vm_size" {
  description = "AKS node VM size."
  type        = string
  default     = "Standard_D2s_v3"
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
  description = "AKS node disk size in GB."
  type        = number
  default     = 50
}

variable "enable_auto_scaling" {
  description = "Enable autoscaling for AKS nodes."
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "AKS Linux admin username."
  type        = string
  default     = "azureuser"
}

variable "public_key" {
  description = "SSH public key for AKS node access. Leave empty to skip SSH configuration."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
