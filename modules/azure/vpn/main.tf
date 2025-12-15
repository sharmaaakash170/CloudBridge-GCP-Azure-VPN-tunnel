resource "azurerm_public_ip" "vpn_ip1" {
  name = "azure-vpn-ip1"
  location = var.location
  resource_group_name = var.rg_name
  allocation_method = "Static"
}

resource "azurerm_public_ip" "vpn_ip2" {
  name = "azure-vpn-ip2"
  location = var.location
  resource_group_name = var.rg_name
  allocation_method = "Static"
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name = "azure-vpn-gateway"
  location = var.location
  resource_group_name = var.rg_name
  type = "Vpn"
  vpn_type = "RouteBased"
  sku = "VpnGw1"
  enable_bgp = true 
  active_active = true

  ip_configuration {
    name = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vpn_ip1.id
    subnet_id = var.gateway_subnet_id
  }

  ip_configuration {
    name = "ipconfig2"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vpn_ip2.id
    subnet_id = var.gateway_subnet_id
  }

  bgp_settings {
    asn = var.azure_bgp_asn

    peering_addresses {
      ip_configuration_name = "ipconfig1"
      apipa_addresses = [ "169.254.21.1" ]
    }
    peering_addresses {
      ip_configuration_name = "ipconfig2"
      apipa_addresses = [ "169.254.22.1" ]
    }
  }
}

resource "azurerm_local_network_gateway" "gcp1" {
  name                = "gcp-network-1"
  location            = var.location
  resource_group_name = var.rg_name

  gateway_address = var.gcp_vpn_ip[0]

  bgp_settings {
    asn                 = var.gcp_bgp_asn
    bgp_peering_address = "169.254.21.2"
  }
}

resource "azurerm_local_network_gateway" "gcp2" {
  name                = "gcp-network-2"
  location            = var.location
  resource_group_name = var.rg_name

  gateway_address = var.gcp_vpn_ip[1]

  bgp_settings {
    asn                 = var.gcp_bgp_asn
    bgp_peering_address = "169.254.22.2"
  }
}



resource "azurerm_virtual_network_gateway_connection" "conn1" {
  name = "azure-to-gcp-conn1"
  location = var.location
  resource_group_name = var.rg_name

  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id = azurerm_local_network_gateway.gcp1.id

  shared_key = var.shared_secret
  enable_bgp = true

  connection_protocol = "IKEv2"
  routing_weight = 10

  

  ipsec_policy {
    ike_encryption = "AES256"
    ike_integrity  = "SHA256"
    dh_group       = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_lifetime      = 3600
    
  }
}

resource "azurerm_virtual_network_gateway_connection" "conn2" {
  name = "azure-to-gcp-conn2"
  location = var.location
  resource_group_name = var.rg_name

  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id = azurerm_local_network_gateway.gcp2.id

  shared_key = var.shared_secret
  enable_bgp = true

  connection_protocol = "IKEv2"
  routing_weight = 10
  ipsec_policy {
    ike_encryption = "AES256"
    ike_integrity  = "SHA256"
    dh_group       = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_lifetime      = 3600
  }
}