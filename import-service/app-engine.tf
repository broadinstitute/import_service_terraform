
resource "google_app_engine_application" "gae_import_service" {
  project     = module.import-service-project.project_name
  location_id = "us-central"
}

