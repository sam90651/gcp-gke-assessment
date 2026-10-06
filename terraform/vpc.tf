resource "google_compute_network" "lab" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "gke" {
  name                     = "gke-primary-subnet"
  region                   = var.region
  network                  = google_compute_network.lab.id
  ip_cidr_range            = "10.10.0.0/22"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-primary-pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-primary-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

resource "google_compute_subnetwork" "gke_east" {
  name                     = "gke-secondary-subnet"
  region                   = var.region_east
  network                  = google_compute_network.lab.id
  ip_cidr_range            = "10.11.0.0/22"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-secondary-pods"
    ip_cidr_range = "10.21.0.0/16"
  }
}

resource "google_compute_firewall" "allow_custom" {
  name    = "lab-vpc-allow-custom"
  network = google_compute_network.lab.name

  source_ranges = [
    "10.10.0.0/22",
    "10.20.0.0/16",
    "10.30.0.0/20",
    "10.11.0.0/22",
    "10.21.0.0/16",
  ]

  allow {
    protocol = "all"
  }
}

resource "google_compute_global_address" "web_a" {
  name = "web-a-ip"

  depends_on = [google_project_service.required]
}