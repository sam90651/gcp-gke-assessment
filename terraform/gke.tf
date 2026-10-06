resource "google_container_cluster" "primary" {
  name     = "gke-primary"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.lab.name
  subnetwork = google_compute_subnetwork.gke.name

  ip_allocation_policy {
    cluster_secondary_range_name = "gke-primary-pods"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
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

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "google_container_cluster" "secondary" {
  name     = "gke-secondary"
  location = var.zone_east

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  network    = google_compute_network.lab.name
  subnetwork = google_compute_subnetwork.gke_east.name

  ip_allocation_policy {
    cluster_secondary_range_name = "gke-secondary-pods"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  depends_on = [google_project_service.required]
}

resource "google_container_node_pool" "secondary" {
  name     = "pool-2"
  location = var.zone_east
  cluster  = google_container_cluster.secondary.name

  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}