output "vm_ids" {
  description = "Azure VM identifiers."
  value       = concat(azurerm_linux_virtual_machine.this[*].id, azurerm_windows_virtual_machine.this[*].id)
}

output "private_ips" {
  description = "Private IP addresses for the Azure VMs."
  value       = azurerm_network_interface.this[*].private_ip_address
}

output "vm_names" {
  description = "Azure VM names."
  value       = concat(azurerm_linux_virtual_machine.this[*].name, azurerm_windows_virtual_machine.this[*].name)
}
