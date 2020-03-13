
resource "google_app_engine_application" "gae_import_service" {
  project     = module.import-service-project.project_name
  location_id = "us-central"
}

# firewall rules that allow broad ips to access GAE
resource "google_app_engine_firewall_rule" "gae_firewall" {
  count = length(var.broad_range_cidrs)
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1000
  action       = "ALLOW"
  source_range = element(var.broad_range_cidrs, count.index)
}
