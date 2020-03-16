resource "google_storage_bucket" "batchupsert_bucket" {
  name = "import-service-batchupsert-${var.env}"
  project = module.import-service-project.project_name
  location = "US"
}

resource "google_storage_bucket_iam_binding" "import_service_owns_batchupsert_bucket" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "roles/storage.admin"
  members = [
      "serviceAccount:import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com",
  ]
}

# Note that default object ACLs aren't visible in cloud console.
# gsutil defacl get gs://yourbucket will show you.
resource "google_storage_default_object_access_control" "rawls_reads_batchupsert_bucket_objects" {
  bucket = google_storage_bucket.batchupsert_bucket.name
  role = "READER"
  entity = "user-${var.rawls_sa_email}"
}
