output "network_id" {
  value = module.vpc.network_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "db_subnet_id" {
  value = module.vpc.db_subnet_id
}

output "instance_names" {
  value = length(module.compute) > 0 ? module.compute[0].instance_names : []
}

output "instance_ids" {
  value = length(module.compute) > 0 ? module.compute[0].instance_ids : []
}

output "gke_cluster_name" {
  value = length(module.gke) > 0 ? module.gke[0].cluster_name : null
}

output "gke_cluster_endpoint" {
  value = length(module.gke) > 0 ? module.gke[0].cluster_endpoint : null
}

output "gke_kubeconfig_command" {
  value = length(module.gke) > 0 ? module.gke[0].kubeconfig_command : null
}

output "bastion_public_ip" {
  value = length(module.bastion) > 0 ? module.bastion[0].bastion_public_ip : null
}

output "bastion_ssh_command" {
  value = length(module.bastion) > 0 ? module.bastion[0].ssh_command : null
}

output "db_connection_name" {
  value = length(module.database) > 0 ? module.database[0].db_connection_name : null
}

output "db_public_ip" {
  value = length(module.database) > 0 ? module.database[0].db_public_ip : null
}

output "db_private_ip" {
  value = length(module.database) > 0 ? module.database[0].db_private_ip : null
}

output "db_engine" {
  value = length(module.database) > 0 ? module.database[0].engine : null
}

output "redis_host" {
  value = length(module.redis) > 0 ? module.redis[0].redis_host : null
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "bucket_url" {
  value = module.storage.bucket_url
}

output "instance_private_ips" {
  description = "Private IP addresses of GCP VMs"
  value       = length(module.compute) > 0 ? module.compute[0].private_ips : []
}

output "instance_zones" {
  description = "Zones of GCP VMs"
  value       = length(module.compute) > 0 ? module.compute[0].zones : []
}
