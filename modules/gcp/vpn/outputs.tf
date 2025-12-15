output "gcp_public_ip" {
  value = google_compute_address.vpc_ip.address
}

output "gcp_bgp_asn" {
  value = google_compute_router.router.bgp
}

output "gcp_vpn_ip" {
  value = google_compute_ha_vpn_gateway.vpn.vpn_interfaces[*].ip_address
}
