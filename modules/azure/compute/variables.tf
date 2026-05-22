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
  description = "Subnet identifier for the VMs."
  type        = string
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

variable "vm_size" {
  description = "Azure VM size."
  type        = string
}

variable "image_os" {
  description = "Azure VM OS selection."
  type        = string
  default     = "ubuntu"
}

variable "admin_username" {
  description = "Administrator username."
  type        = string
}

variable "admin_password" {
  description = "Administrator password."
  type        = string
  sensitive   = true
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30
}

variable "assign_public_ip" {
  description = "Assign a public IP to each VM."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
