output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_key_name" {
  value = aws_key_pair.bastion.key_name
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "ssh_command" {
  value = "ssh -i <key> ec2-user@${aws_instance.bastion.public_ip}"
}
