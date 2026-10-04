resource "google_container_cluster" "primary" {
  name     = "gke-primary"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.lab.name
  subnetwork = google_compute_subnetwork.gke.name

  # Pods use the subnet secondary range. 
  ip_allocation_policy {
    cluster_secondary_range_name = "gke-primary-pods"
  }

  depends_on = [google_project_service.required]
}

resource "google_container_node_pool" "pool_2" {
  name     = "pool-2"
  location = var.zone
  cluster  = google_container_cluster.primary.name

  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 30
    disk_type    = "pd-standard"

    # Default GKE scopes omit BigQuery and Cloud Resource Manager.
    # Scopes cannot be changed after the pool is created.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}