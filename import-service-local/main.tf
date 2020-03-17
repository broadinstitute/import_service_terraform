module "import-service" {
  source = "../import-service"

  env = var.env
  bucket_suffix = var.bucket_suffix
  import_service_google_project = var.import_service_google_project
  import_service_google_project_folder_id = var.import_service_google_project_folder_id
  billing_account_id = var.billing_account_id

  audience_domain = var.audience_domain
  rawls_sa_email = var.rawls_sa_email
  sam_sa_email = var.sam_sa_email
  terra_google_project = var.terra_google_project

  vault_path = var.vault_path

  providers = {
    google.target = google
    google-beta.target = google-beta
  }
}
