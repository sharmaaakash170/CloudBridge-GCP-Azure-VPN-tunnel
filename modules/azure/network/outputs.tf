output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway.id
}

output "vm_subnet_id" {
  value = azurerm_subnet.vm_subnet.id
}

output "vm_private_ip" {
  value = azurerm_network_interface.interface.ip_configuration[0].private_ip_address
}

output "azure_interface_id" {
  value = azurerm_network_interface.interface.id
}