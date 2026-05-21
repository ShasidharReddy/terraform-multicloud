terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

locals {
  sku_defaults = {
    dev   = { family = "C", capacity = 1, sku_name = "Standard" }
    qa    = { family = "C", capacity = 1, sku_name = "Standard" }
    stage = { family = "C", capacity = 2, sku_name = "Standard" }
    prod  = { family = "P", capacity = 1, sku_name = "Premium" }
  }
  sku = lookup(local.sku_defaults, var.environment, local.sku_defaults["dev"])
}

resource "azurerm_redis_cache" "this" {
  name                 = lower("${var.project}-${var.environment}-redis")
  location             = var.location
  resource_group_name  = var.resource_group_name
  capacity             = var.capacity != null ? var.capacity : local.sku.capacity
  family               = var.family != null ? var.family : local.sku.family
  sku_name             = var.sku_name != null ? var.sku_name : local.sku.sku_name
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"
  redis_version        = var.redis_version

  redis_configuration {
    maxmemory_policy = var.maxmemory_policy
  }

  tags = var.tags
}
