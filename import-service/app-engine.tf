
resource "google_app_engine_application" "gae_import_service" {
  project     = module.import-service-project.project_name
  location_id = "us-central"
}

# firewall rules that allow broad ips to access GAE
# This doesn't work, see https://github.com/terraform-providers/terraform-provider-google/issues/5681
#resource "google_app_engine_firewall_rule" "gae_firewall" {
#  count = length(var.broad_range_cidrs)
#  project      = google_app_engine_application.gae_import_service.project
#  priority     = 1000 + count.index
#  action       = "ALLOW"
#  source_range = element(var.broad_range_cidrs, count.index)
#}

# default-deny firewall rule
resource "google_app_engine_firewall_rule" "gae_firewall_default" {
  project      = google_app_engine_application.gae_import_service.project

  # priority is MAX_INT-1. MAX_INT is the priority indicating the "default" rule. i can edit that rule from
  # cloud console but setting it in terraform gives an error. so we'll set a DENY at the second lowest prio instead.
  priority     = 2147483646
  action       = "DENY"
  source_range = "*"
}
