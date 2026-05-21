variable "project" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.0"
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to connect to Redis."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
