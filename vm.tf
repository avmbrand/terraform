resource "google_compute_instance" "vm_instance" {
  name         = "jenkins-vm"
  machine_type = "e2-medium" 
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = 20
    }
  }


  network_interface {
    network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet_1.name

    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    email = "kubernetes-sa@uberfreightdevops.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

variable "ssh_username" {
  description = "The username for SSH access"
  type        = string
  default     = "appuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_ecdsa_gcp_vm.pub"
}

output "instance_name" {
  value = google_compute_instance.vm_instance.name
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
