resource "google_compute_network" "this" {
  name = "gcp-vpc"
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "this" {
  name = "gcp-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  network = google_compute_network.this.id
  region = var.gcp_region
}

resource "google_compute_firewall" "this" {
  name = "ssh-icmp-and-http-firewall"
  network = google_compute_network.this.name

  direction = "INGRESS"

  source_ranges = [ "0.0.0.0/0" ]

  target_tags = [ "env" ]

  allow {
    protocol = "tcp"
    ports = [ "80", "22", "443" ]
  }
  
  allow {
    protocol = "udp"
    ports = [ "80", "22", "443"]
  }
}

resource "google_compute_firewall" "icmp_firewall" {
  name = "icmp-firewall"
  network = google_compute_network.this.name
  direction = "INGRESS"
  source_ranges = [ "0.0.0.0/0" ]

  target_tags = [ "env" ]

  allow {
    protocol = "icmp"
  }
}