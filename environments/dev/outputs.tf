output "azure_public_ip_1" {
  value = module.azure_vpn.azure_public_ip_1
}

output "azure_public_ip_2" {
  value = module.azure_vpn.azure_public_ip_2
}

output "azure_bgp_asn" {
  value = module.azure_vpn.azure_bgp_asn
}

output "gcp_public_ip" {
  value = module.gcp_vpn.gcp_public_ip
}

output "gcp_bgp_asn" {
  value = module.gcp_vpn.gcp_bgp_asn
}

output "gcp_vpn_interface_ips" {
  value = module.gcp_vpn.gcp_vpn_ip
}