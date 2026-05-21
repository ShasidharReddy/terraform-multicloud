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

variable "bastion_sg_id" {
  description = "Bastion security group identifier. Leave empty to skip bastion SSH ingress rules."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
