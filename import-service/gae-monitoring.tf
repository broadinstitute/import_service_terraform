module "gae_monitoring" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/stackdriver/gae-monitoring?ref=da_api-services-1.0.0"
  providers = {
    google.target = google
  }
  service_name     = "importservice-${var.env}"
  gae_host_project = var.import_service_google_project
}
