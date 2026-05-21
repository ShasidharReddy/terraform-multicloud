output "web_sg_id" {
  value = aws_security_group.web.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "redis_sg_id" {
  description = "Redis security group ID."
  value       = aws_security_group.redis.id
}

output "eks_workers_sg_id" {
  value = aws_security_group.eks_workers.id
}
