output "resource_group_name" {
  value = module.vnet.resource_group_name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "public_subnet_id" {
  value = module.vnet.public_subnet_id
}

output "private_subnet_id" {
  value = module.vnet.private_subnet_id
}

output "db_subnet_id" {
  value = module.vnet.db_subnet_id
}

output "vm_ids" {
  value = module.compute.vm_ids
}

output "vm_private_ips" {
  value = module.compute.private_ips
}

output "db_fqdn" {
  value = module.database.db_fqdn
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "container_name" {
  value = module.storage.container_name
}
