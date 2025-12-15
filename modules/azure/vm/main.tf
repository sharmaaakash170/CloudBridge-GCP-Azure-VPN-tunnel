resource "azurerm_linux_virtual_machine" "this" {
  name = "${var.env}-azure-vm"
  location = var.location
  resource_group_name = var.rg_name
  size = var.vm_size
  network_interface_ids = [ 
    var.network_interface_ids 
  ]

  admin_username = var.admin_username
  disable_password_authentication = true
  admin_ssh_key {
    username = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching = var.caching
    storage_account_type = var.managed_disk_type
  }

  source_image_reference {
    publisher = var.publisher
    offer = var.offer
    sku = var.sku
    version = "latest"
  }
  tags = {
    environment = var.env 
  }
}
