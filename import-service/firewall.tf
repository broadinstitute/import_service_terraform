# firewall rules that allow broad ips to access GAE
# FIXME This doesn't work, see https://github.com/terraform-providers/terraform-provider-google/issues/5681
# The ATTENTION output in output.tf and associated script is the workaround for the time being.
resource "google_app_engine_firewall_rule" "broad_firewall" {
  count        = length(var.broad_range_cidrs)
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1000 + count.index
  action       = "ALLOW"
  source_range = element(var.broad_range_cidrs, count.index)
}

# import-service must whitelist back-rawls in each environment

data "google_compute_instance" "back_rawls" {
  name    = var.back_rawls_instance
  project = "broad-dsde-${var.env}"
  zone    = "us-central1-a"
}

# back rawls makes calls to import-service and must be whitelisted
resource "google_app_engine_firewall_rule" "back_rawls_firewall" {
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1000 + length(var.broad_range_cidrs)
  action       = "ALLOW"
  source_range = "${data.google_compute_instance.back_rawls.network_interface.0.access_config.0.nat_ip}"
}

# import-service needs to whitelist pubsub
resource "google_app_engine_firewall_rule" "pubsub_firewall" {
  project      = google_app_engine_application.gae_import_service.project
  priority     = 1020
  action       = "ALLOW"
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
  source_range = "${data.google_compute_instance.orchestration[count.index].network_interface.0.access_config.0.nat_ip}"
}

# Whitelist terra GKE cluster egress IPs

# Load remote state for each cluster/workspace from the terra-cluster root module
# Access like this:
#   data.terraform_remote_state.terra-cluster[$cluster].outputs.egress_ips
data "terraform_remote_state" "cluster" {
  for_each = var.clusters_to_whitelist

  backend   = "gcs"
  workspace = each.key # "integration" cluster uses "integration" workspace etc

  config = {
    bucket = local.remote_state_bucket
    prefix = "${local.remote_state_path}/terra-cluster"

    credentials = var.google_credentials
  }
}

# Extract the cluster egress ips from terraform state and transform data to a form usable by the 
# app engine firewall resource
locals {
  cluster_egress_outputs = [for cluster in data.terraform_remote_state.cluster : cluster.outputs.egress_ips]
  egress_ips             = [for ip in tolist(local.cluster_egress_outputs) : ip]
}

resource "google_app_engine_firewall_rule" "k8s_egress_firewall" {
  count = length(local.egress_ips)

  project      = google_app_engine_application.gae_import_service.project
  priority     = 1040 + count.index
  action       = "ALLOW"
  source_range = "${local.egress_ips[count.index]}"
}

# default-deny firewall rule
resource "google_app_engine_firewall_rule" "firewall_default_deny" {
  project = google_app_engine_application.gae_import_service.project

  # priority is MAX_INT-1. MAX_INT is the priority indicating the "default" rule. i can edit that rule from
  # cloud console but setting it in terraform gives an error. so we'll set a DENY at the second lowest prio instead.
  priority     = 2147483646
  action       = "DENY"
  source_range = "*"
}
