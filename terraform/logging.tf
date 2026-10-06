resource "google_bigquery_dataset" "gke_logs" {
  dataset_id = "gke_logs"
  location   = var.region

  depends_on = [google_project_service.required]
}

resource "google_logging_project_sink" "app" {
  name        = "gke-app-logs"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.gke_logs.dataset_id}"

  filter = <<-EOT
    resource.type="k8s_container"
    AND resource.labels.cluster_name=("gke-primary" OR "gke-secondary")
    AND resource.labels.namespace_name="web"
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }

  depends_on = [google_project_service.required]
}

resource "google_logging_project_sink" "cluster" {
  name        = "gke-cluster-logs"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.gke_logs.dataset_id}"

  filter = <<-EOT
    resource.type=("k8s_node" OR "k8s_pod" OR "k8s_cluster" OR "k8s_control_plane_component")
    AND resource.labels.cluster_name=("gke-primary" OR "gke-secondary")
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset_iam_member" "app_sink_writer" {
  dataset_id = google_bigquery_dataset.gke_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.app.writer_identity
}

resource "google_bigquery_dataset_iam_member" "cluster_sink_writer" {
  dataset_id = google_bigquery_dataset.gke_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.cluster.writer_identity
}


resource "google_project_iam_member" "node_bigquery_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "node_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}