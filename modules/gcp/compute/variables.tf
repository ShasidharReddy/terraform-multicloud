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

variable "zone" {
  description = "GCP zone."
  type        = string
}

variable "network_self_link" {
  description = "Network self link."
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork identifier or self link."
  type        = string
}

variable "vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "vm_count must be between 1 and 10."
  }
}

variable "machine_type" {
  description = "GCP machine type."
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 30
}

variable "image" {
  description = "Boot image."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "tags" {
  description = "GCP labels."
  type        = map(string)
  default     = {}
}
