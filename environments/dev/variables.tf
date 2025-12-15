variable "gcp_project_id" {}
variable "gcp_region" {}
variable "azure_location" {}
variable "resource_group_name" {}
variable "shared_secret" { description = "VPN pre-shared key" }

# Azure VM variables
variable "vm_size" {}
variable "publisher" {}
variable "offer" {}
variable "sku" {}
variable "caching" {}
variable "create_option" {}
variable "managed_disk_type" {}
variable "computer_name" {}
variable "admin_username" {}
variable "env" {}
variable "ssh_public_key_path" {}
variable "azure_vnet_cidr" {}

# GCP VM variables
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "interface" {}
variable "gcp_vpc_cidr" {}
variable "gcp_subnet_cidr" {}
