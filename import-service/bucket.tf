resource "google_storage_bucket" "batchupsert_bucket" {
  name = "import-service-batchupsert-${local.bucket_suffix}"
  project = module.import-service-project.project_name
  uniform_bucket_level_access = true
  location = "US"
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_binding" "import_service_owns_batchupsert_bucket" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "roles/storage.admin"
  members = var.env == "qa" ? [
    "serviceAccount:import-service-fiab@broad-dsde-qa.iam.gserviceaccount.com", "serviceAccount:${local.import_service_sa_email}",
  ] : ["serviceAccount:${local.import_service_sa_email}", ]
  depends_on = [module.import-service-project.service_accounts_with_keys]
}

  
resource "google_storage_bucket_iam_binding" "rawls_creator_batchupsert_bucket" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "roles/storage.objectCreator"
  members = [
      "serviceAccount:${var.rawls_sa_email}",
  ]
  depends_on = [module.import-service-project.service_accounts_with_keys]
}

resource "google_storage_bucket_iam_binding" "rawls_viewer_batchupsert_bucket" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "roles/storage.objectViewer"
  members = [
      "serviceAccount:${var.rawls_sa_email}",
  ]
  depends_on = [module.import-service-project.service_accounts_with_keys]
}

