shared_secret = "super-secret-key"
env = "dev"

# GCP Variables
gcp_project_id = "terraform-project-452412"
gcp_region     = "asia-south1"
machine_type = "n2-standard-2"
zone = "asia-south1-a"
image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-minimal-2204-lts"
interface =  "NVME"
gcp_vpc_cidr = "10.10.0.0/16"
gcp_subnet_cidr = "10.10.1.0/24"

# Azure Variables
azure_location       = "Central India"
resource_group_name  = "vpn-rg"
azure_vnet_cidr = "10.20.0.0/16"

vm_size = "Standard_B1s"
publisher = "Canonical"
offer = "0001-com-ubuntu-server-jammy"
sku = "22_04-lts"

caching = "ReadWrite"
create_option = "FromImage"
managed_disk_type =  "Standard_LRS"

computer_name = "hostname"
admin_username = "aakash"

ssh_public_key_path = "~/.ssh/azure_vm_key.pub"
