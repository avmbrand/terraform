resource "google_container_cluster" "gke_cluster" {
  name = "cluster-1"
  location = "us-central1-c"
  workload_identity_config {
      workload_pool = "uberfreightdevops.svc.id.goog"
  }
  release_channel {
    channel = "REGULAR"
  }
  initial_node_count = 1
  min_master_version = "1.30.5-gke.1713000"
  network = "my-vpc-network"
  subnetwork = "gke-subnet"
  remove_default_node_pool = true 
private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes   = true 
    master_ipv4_cidr_block = "10.10.0.0/28"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.11.0.0/16"
    services_ipv4_cidr_block = "10.12.0.0/16"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.1.0/24"
      display_name = "VPC Network"
    }
  }
}

resource "google_container_node_pool" "gke_node_pool-1" {
  name       = "gke-node-pool-1"
  cluster    = google_container_cluster.gke_cluster.name
  location   = google_container_cluster.gke_cluster.location

  node_config {
    machine_type = "e2-medium" 
    labels = {
      environment = "dev"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
  }

  initial_node_count = 1
  
}

resource "google_container_node_pool" "gke_autoscaling_node_pool" {
  name       = "autoscaling-node-pool"
  cluster    = google_container_cluster.gke_cluster.name
  location   = google_container_cluster.gke_cluster.location

  node_config {
    machine_type = "e2-medium" 
    labels = {
      environment = "prod"
    }
    oauth_scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
  metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  initial_node_count = 1
}


output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}
