module "gae_monitoring" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/stackdriver/gae-monitoring?ref=gae-monitoring-0.0.2-tf-0.12"
  providers = {
    google.target = google.target
  }
  service_name     = "importservice-${var.env}"
  gae_host_project = var.import_service_google_project
}
