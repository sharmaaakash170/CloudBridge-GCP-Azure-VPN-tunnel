module "gcp_network" {
  source = "../../modules/gcp/network"
  vpc_cidr = var.gcp_vpc_cidr
  gcp_subnet_cidr = var.gcp_subnet_cidr
  gcp_region = var.gcp_region
}

module "azure_network" {
  source = "../../modules/azure/network"
  azure_vnet_cidr = var.azure_vnet_cidr
  location = var.azure_location
  rg_name = var.resource_group_name
}

module "gcp_vpn" {
  source = "../../modules/gcp/vpn"
  gcp_region = var.gcp_region
  shared_secret = var.shared_secret
  network_id = module.gcp_network.network_id
  azure_vpn_ip_1 = module.azure_vpn.azure_public_ip_1
  azure_vpn_ip_2 = module.azure_vpn.azure_public_ip_2
  azure_bgp_asn = module.azure_vpn.azure_bgp_asn
}

module "azure_vpn" {
  source = "../../modules/azure/vpn"
  shared_secret = var.shared_secret
  rg_name = var.resource_group_name
  location = var.azure_location
  gcp_vpn_ip = module.gcp_vpn.gcp_vpn_ip
  gcp_vpc_cidr = var.gcp_vpc_cidr
  gateway_subnet_id = module.azure_network.gateway_subnet_id
  azure_bgp_asn =  65515
  gcp_bgp_ip = "169.254.21.2"
  gcp_bgp_asn = 65001
}

module "gcp_vm" {
  source = "../../modules/gcp/vm"
  machine_type = var.machine_type
  zone = var.zone 
  image = var.image 
  interface = var.interface 
  network = module.gcp_network.network_id
  subnetwork = module.gcp_network.subnetwork_id
  env = var.env 
  admin_username = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  depends_on = [ module.gcp_network, module.gcp_vpn ]
}

module "azure_vm" {
  source = "../../modules/azure/vm"
  vm_size = var.vm_size
  location = var.azure_location
  rg_name = var.resource_group_name
  network_interface_ids = module.azure_network.azure_interface_id
  publisher = var.publisher
  offer = var.offer
  sku = var.sku
  caching = var.caching
  create_option = var.create_option
  managed_disk_type = var.managed_disk_type
  computer_name = var.computer_name
  admin_username = var.admin_username
  env = var.env 
  ssh_public_key_path = var.ssh_public_key_path

  depends_on = [ module.azure_network, module.azure_vpn ]
}