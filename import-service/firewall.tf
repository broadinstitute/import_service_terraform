# firewall rules that allow broad ips to access GAE
resource "google_app_engine_firewall_rule" "broad_firewall" {
  count        = length(var.broad_range_cidrs)
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1000 + count.index
  action       = "ALLOW"
  description  = "Broad office ips"
  source_range = element(var.broad_range_cidrs, count.index)
}

# import-service must whitelist back-rawls in each environment

data "google_compute_instance" "back_rawls" {
  name    = var.back_rawls_instance
  project = "broad-dsde-${var.env}"
  zone    = "us-central1-a"
}

resource "google_app_engine_firewall_rule" "back_rawls_firewall" {
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1000 + length(var.broad_range_cidrs)
  action       = "ALLOW"
  description  = "back-rawls vm"
  source_range = "${data.google_compute_instance.back_rawls.network_interface.0.access_config.0.nat_ip}"
}

# import-service needs to whitelist pubsub
resource "google_app_engine_firewall_rule" "pubsub_firewall" {
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1020
  action       = "ALLOW"
  description  = "pubsub"
  source_range = var.pubsub_ip_range
}

# Import service must allow traffic from each firecloud orchestration instances in an environment

# look up the ip of each orch instance
data "google_compute_instance" "orchestration" {
  count   = length(var.orchestration_instances)
  name    = var.orchestration_instances[count.index]
  project = "broad-dsde-${var.env}"
  zone    = "us-central1-a"
}

resource "google_app_engine_firewall_rule" "orchestration_firewall" {
  count = length(var.orchestration_instances)

  project      = google_app_engine_application.gae_import_service.project
  priority     = 1030 + count.index
  action       = "ALLOW"
  description  = "firecloud-orchestration vms"
  source_range = "${data.google_compute_instance.orchestration[count.index].network_interface.0.access_config.0.nat_ip}"
}

# This is needed due to details of google's internal networking between gae and gke
# This is not a default allow all traffic rule. In this context 0.0.0.0
# enables Private Google Access which is how gke communicates with gae
# internally. More information: https://cloud.google.com/vpc/docs/configure-private-google-access
resource "google_app_engine_firewall_rule" "gke_gae_vpc_firewall" {
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1050
  action       = "ALLOW"
  description  = "gcp internal network from gke to gae"
  source_range = "0.0.0.0"
}

# default-deny firewall rule
resource "google_app_engine_firewall_rule" "firewall_default_deny" {
  project = google_app_engine_application.gae_import_service.project

  # priority is MAX_INT-1. MAX_INT is the priority indicating the "default" rule. i can edit that rule from
  # cloud console but setting it in terraform gives an error. so we'll set a DENY at the second lowest prio instead.
  priority     = 2147483646
  action       = "DENY"
  description  = "default deny"
  source_range = "*"
}
