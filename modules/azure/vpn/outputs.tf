output "azure_public_ip_1" {
  value = azurerm_public_ip.vpn_ip1.ip_address
}

output "azure_public_ip_2" {
  value = azurerm_public_ip.vpn_ip2.ip_address
}

output "azure_bgp_asn" {
  value = azurerm_virtual_network_gateway.vpn.bgp_settings[0].asn
}