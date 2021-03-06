resource "google_storage_bucket" "batchupsert_bucket" {
  name = "import-service-batchupsert-${local.bucket_suffix}"
  project = module.import-service-project.project_name
  location = "US"
}

resource "google_storage_bucket_iam_binding" "import_service_owns_batchupsert_bucket" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "roles/storage.admin"
  members = [
      "serviceAccount:${local.import_service_sa_email}",
  ]
  depends_on = [module.import-service-project.service_accounts_with_keys]
}

# Note that default object ACLs aren't visible in cloud console.
# gsutil defacl get gs://yourbucket will show you.
resource "google_storage_default_object_access_control" "rawls_reads_batchupsert_bucket_objects" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "READER"
  entity = "user-${var.rawls_sa_email}"
}
