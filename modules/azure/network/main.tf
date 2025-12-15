resource "azurerm_virtual_network" "this" {
  name = "azure-vnet"
  address_space = [ var.azure_vnet_cidr ]
  location = var.location
  resource_group_name = var.rg_name 
}

resource "azurerm_subnet" "gateway" {
  name = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name = var.rg_name
  address_prefixes = [ "10.20.255.0/27" ]
}

resource "azurerm_subnet" "vm_subnet" {
  name = "vm-subnet"
  virtual_network_name = azurerm_virtual_network.this.name
  resource_group_name = var.rg_name
  address_prefixes = [ "10.20.1.0/24" ]
}

resource "azurerm_network_interface" "interface" {
  name = "net-interface"
  location = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name = "ipconfig"
    subnet_id = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name = "vm-nsg"
  location = var.location
  resource_group_name = var.rg_name

  security_rule {
    name = "Allow-SSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Allow-HTTP"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Allow-ICMP-from-GCP"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Icmp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id = azurerm_network_interface.interface.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_public_ip" "public_ip" {
  name = "azure-public-ip"
  location = var.location
  sku = "Standard"
  allocation_method = "Static"
  resource_group_name = var.rg_name
}