resource "google_compute_address" "vpc_ip" {
  name = "gcp-vpn-ip"
  region = var.gcp_region
}

resource "google_compute_ha_vpn_gateway" "vpn" {
  name = "gcp-ha-vpn"
  region = var.gcp_region
  network = var.network_id
}

resource "google_compute_router" "router" {
  name = "gcp-router"
  network = var.network_id
  region = var.gcp_region
  bgp {
    asn = 65001
  }
}

resource "google_compute_external_vpn_gateway" "azure" {
  name = "azure-external-gateway"

  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id = 0
    ip_address = var.azure_vpn_ip_1
  }

  interface {
    id = 1 
    ip_address = var.azure_vpn_ip_2
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name = "gcp-to-azure-t1"
  region = var.gcp_region
  vpn_gateway = google_compute_ha_vpn_gateway.vpn.id
  vpn_gateway_interface = 0
  # peer_ip = var.azure_vpn_ip_1 
  peer_external_gateway = google_compute_external_vpn_gateway.azure.id
  peer_external_gateway_interface = 0

  shared_secret = var.shared_secret
  router = google_compute_router.router.id
  ike_version = 2 
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name = "gcp-to-azure-t2"
  region = var.gcp_region
  vpn_gateway = google_compute_ha_vpn_gateway.vpn.id
  vpn_gateway_interface = 1

  peer_external_gateway = google_compute_external_vpn_gateway.azure.id
  peer_external_gateway_interface = 1
  
  shared_secret = var.shared_secret
  router = google_compute_router.router.id
  ike_version = 2 
}

resource "google_compute_router_interface" "if1" {
  name = "if-tunnel1"
  router = google_compute_router.router.name
  region = var.gcp_region
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
  ip_range = "169.254.21.2/30"
}

resource "google_compute_router_interface" "if2" {
  name = "if-tunnel2"
  router = google_compute_router.router.name
  region = var.gcp_region
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
  ip_range = "169.254.22.2/30"
}

resource "google_compute_router_peer" "peer1" {
  name = "azure-peer1"
  router = google_compute_router.router.name
  region = var.gcp_region
  interface = google_compute_router_interface.if1.name
  peer_ip_address = "169.254.21.1"
  peer_asn = var.azure_bgp_asn
}

resource "google_compute_router_peer" "peer2" {
  name = "azure-peer2"
  router = google_compute_router.router.name
  region = var.gcp_region
  interface = google_compute_router_interface.if2.name
  peer_ip_address = "169.254.22.1"
  peer_asn = var.azure_bgp_asn
}

