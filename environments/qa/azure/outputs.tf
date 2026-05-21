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
  value = length(module.compute) > 0 ? module.compute[0].vm_ids : []
}

output "vm_private_ips" {
  value = length(module.compute) > 0 ? module.compute[0].private_ips : []
}

output "aks_cluster_name" {
  value = length(module.aks) > 0 ? module.aks[0].cluster_name : null
}

output "aks_host" {
  value = length(module.aks) > 0 ? module.aks[0].host : null
}

output "aks_kubeconfig_command" {
  value = length(module.aks) > 0 ? module.aks[0].kubeconfig_command : null
}

output "bastion_public_ip" {
  value = length(module.bastion) > 0 ? module.bastion[0].bastion_public_ip : null
}

output "bastion_ssh_command" {
  value = length(module.bastion) > 0 ? module.bastion[0].ssh_command : null
}

output "db_fqdn" {
  value = length(module.database) > 0 ? module.database[0].db_fqdn : null
}

output "db_engine" {
  value = length(module.database) > 0 ? module.database[0].engine : null
}

output "redis_hostname" {
  value = length(module.redis) > 0 ? module.redis[0].redis_hostname : null
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "container_name" {
  value = module.storage.container_name
}
