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

variable "bucket_name_suffix" {
  description = "Suffix used for the GCS bucket name."
  type        = string
}

variable "storage_class" {
  description = "GCS storage class."
  type        = string
  default     = "STANDARD"
}

variable "tags" {
  description = "GCS labels."
  type        = map(string)
  default     = {}
}
