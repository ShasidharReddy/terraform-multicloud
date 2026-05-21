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
  description = "GCP region for the GKE cluster."
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link."
  type        = string
}

variable "subnetwork_self_link" {
  description = "Subnetwork self link for the GKE cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Minimum Kubernetes control plane version."
  type        = string
  default     = "1.29"
}

variable "machine_type" {
  description = "GKE node machine type."
  type        = string
  default     = "e2-medium"
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

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "cluster_ipv4_cidr" {
  description = "CIDR block for GKE pods."
  type        = string
  default     = "172.20.0.0/16"
}

variable "services_ipv4_cidr" {
  description = "CIDR block for GKE services."
  type        = string
  default     = "172.21.0.0/22"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the private GKE control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "tags" {
  description = "GCP labels."
  type        = map(string)
  default     = {}
}
