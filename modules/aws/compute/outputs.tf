output "instance_ids" {
  description = "EC2 instance identifiers."
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "Private IP addresses of the instances."
  value       = aws_instance.this[*].private_ip
}

output "security_group_id" {
  description = "Security group identifier."
  value       = aws_security_group.this.id
}
