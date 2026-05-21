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

variable "account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage replication type."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
