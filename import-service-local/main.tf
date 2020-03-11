module "import-service" {
  source = "github.com/broadinstitute/import_service_terraform.git//import-service?ref=wip"

  env = var.env
  owner = var.owner
  import_service_google_project = var.import_service_google_project
  import_service_google_project_folder_id = var.import_service_google_project_folder_id
  billing_account_id = var.billing_account_id

  audience_domain = var.audience_domain
  rawls_sa_email = var.rawls_sa_email

  providers = {
    google.target = google
    google-beta.target = google-beta
  }
}
