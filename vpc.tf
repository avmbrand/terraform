resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "vm-subnet"
  region        = "us-central1" 
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "gke-subnet"
  region        = "us-central1" 
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.2.0.0/24"
}


resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22","8080"] 
  }

  source_ranges = ["0.0.0.0/0"] 
}