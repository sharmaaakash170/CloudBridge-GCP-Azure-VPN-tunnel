resource "google_service_account" "this" {
  display_name = "Custom SA for vm"
  account_id = "gcp-vm-sa"
}

resource "google_compute_instance" "gcp_vm" {
  name = "${var.env}-gcp-vm"
  machine_type = var.machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      labels = {
        "vm" = "test" 
      }
    }
  }

  metadata = {
    ssh-keys = "${var.admin_username}:${file(var.ssh_public_key_path)}"
  }

  scratch_disk {
    interface = var.interface
  }

  network_interface {
    network = var.network
    subnetwork = var.subnetwork

    access_config {}
  }

  service_account {
    email = google_service_account.this.email
    scopes = [ "cloud-platform" ]
  }

  tags = [ 
    "env"
   ]
}