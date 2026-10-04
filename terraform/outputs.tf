output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_zone" {
  value = google_container_cluster.primary.location
}

output "web_a_ip" {
  description = "Reserved global address name web-a-ip. The live lab address is 136.81.187.221. A new apply receives a new address."
  value       = google_compute_global_address.web_a.address
}

output "logs_dataset" {
  value = google_bigquery_dataset.gke_logs.id
}