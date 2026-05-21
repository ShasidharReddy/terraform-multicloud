variable "project" { type = string }
variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "capacity" {
  type        = number
  default     = null
  description = "Override Redis capacity (null = env default)"
}

variable "family" {
  type        = string
  default     = null
  description = "Override Redis family C or P (null = env default)"
}

variable "sku_name" {
  type        = string
  default     = null
  description = "Override SKU: Basic, Standard, Premium (null = env default)"
}

variable "redis_version" {
  type        = number
  default     = 7
  description = "Redis major version (6 or 7)"
}

variable "maxmemory_policy" {
  type    = string
  default = "allkeys-lru"
}

variable "tags" {
  type    = map(string)
  default = {}
}
