resource "google_artifact_registry_repository" "web_a" {
  location      = var.region
  repository_id = "web-a"
  description   = "web-a container images"
  format        = "DOCKER"

  depends_on = [google_project_service.required]
}

# Nodes pull images with the Compute Engine default SA (kubelet), not the pod WI identity.
resource "google_artifact_registry_repository_iam_member" "node_reader" {
  project    = var.project_id
  location   = google_artifact_registry_repository.web_a.location
  repository = google_artifact_registry_repository.web_a.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}