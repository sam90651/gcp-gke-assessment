resource "google_dns_managed_zone" "web" {
  name        = "my-web-app"
  dns_name    = "web-lab-app.org."
  description = "Lab DNS for the global load balancer"
  visibility  = "public"

  depends_on = [google_project_service.required]
}

resource "google_dns_record_set" "apex" {
  name         = google_dns_managed_zone.web.dns_name
  managed_zone = google_dns_managed_zone.web.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.web_a.address]
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.web.dns_name}"
  managed_zone = google_dns_managed_zone.web.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.web_a.address]
}