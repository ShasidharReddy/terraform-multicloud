output "vm_ids" {
  description = "Azure VM identifiers."
  value       = azurerm_linux_virtual_machine.this[*].id
}

output "private_ips" {
  description = "Private IP addresses for the Azure VMs."
  value       = azurerm_network_interface.this[*].private_ip_address
}

output "vm_names" {
  description = "Azure VM names."
  value       = azurerm_linux_virtual_machine.this[*].name
}
