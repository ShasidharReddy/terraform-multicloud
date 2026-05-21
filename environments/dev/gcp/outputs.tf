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
  value = module.compute.instance_names
}

output "instance_ids" {
  value = module.compute.instance_ids
}

output "db_connection_name" {
  value = module.database.db_connection_name
}

output "db_public_ip" {
  value = module.database.db_public_ip
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "bucket_url" {
  value = module.storage.bucket_url
}
