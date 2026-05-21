output "redis_endpoint" {
  description = "Redis primary endpoint."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "redis_port" {
  value = 6379
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
