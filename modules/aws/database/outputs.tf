output "db_endpoint" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].endpoint : aws_rds_cluster.aurora[0].endpoint
}

output "db_reader_endpoint" {
  value = length(aws_rds_cluster.aurora) > 0 ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "db_port" {
  value = length(aws_db_instance.this) > 0 ? aws_db_instance.this[0].port : aws_rds_cluster.aurora[0].port
}

output "db_name" {
  value = var.db_name
}

output "engine" {
  value = var.engine
}
