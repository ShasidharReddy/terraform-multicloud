variable "project_id" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type    = string
  default = ""
}

variable "network_self_link" {
  type = string
}

variable "memory_size_gb" {
  type    = number
  default = 1
}

variable "redis_version" {
  type    = string
  default = "REDIS_7_0"
}

variable "maxmemory_policy" {
  type    = string
  default = "allkeys-lru"
}

variable "tags" {
  type    = map(string)
  default = {}
}
