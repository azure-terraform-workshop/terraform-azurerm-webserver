output "vm-ids" {
  value       = "${azurerm_virtual_machine.module.*.id}"
  description = "Virtual Machine Id's"
}

output "private-ips" {
  value       = "${azurerm_network_interface.module.*.private_ip_address}"
  description = "Private IP Addresses"
}
