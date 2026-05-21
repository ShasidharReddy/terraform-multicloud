output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "instance_ids" {
  value = length(module.compute) > 0 ? module.compute[0].instance_ids : []
}

output "instance_private_ips" {
  value = length(module.compute) > 0 ? module.compute[0].private_ips : []
}

output "eks_cluster_name" {
  value = length(module.eks) > 0 ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  value = length(module.eks) > 0 ? module.eks[0].cluster_endpoint : null
}

output "eks_kubeconfig_command" {
  value = length(module.eks) > 0 ? module.eks[0].kubeconfig_command : null
}

output "bastion_public_ip" {
  value = length(module.bastion) > 0 ? module.bastion[0].bastion_public_ip : null
}

output "bastion_ssh_command" {
  value = length(module.bastion) > 0 ? module.bastion[0].ssh_command : null
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_reader_endpoint" {
  value = module.database.db_reader_endpoint
}

output "db_port" {
  value = module.database.db_port
}

output "db_engine" {
  value = module.database.engine
}

output "bucket_id" {
  value = module.storage.bucket_id
}

output "bucket_arn" {
  value = module.storage.bucket_arn
}
