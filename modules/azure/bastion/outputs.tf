output "bastion_public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}
