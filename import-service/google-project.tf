module "import-service-project" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/google-project?ref=google_project_number"

  project_name = var.import_service_google_project
  folder_id = var.import_service_google_project_folder_id
  billing_account_id = var.billing_account_id
  apis_to_enable = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "appengine.googleapis.com",
    "pubsub.googleapis.com",
    "storage-component.googleapis.com"
  ]
  service_accounts_to_create_with_keys = [
    {
      sa_name = "import-service"
      key_vault_path = "${vault_root}/${vault_path}/import-service-account.json"
    }
  ]
  roles_to_grant_by_email_and_type = []
  service_accounts_to_grant_by_name_and_project = [{
    sa_role = "roles/pubsub.admin"
    sa_name = "import-service"
    sa_project = "" // defaults to the created project
  },{
    sa_role = "roles/iam.serviceAccountTokenCreator"
    sa_name = "import-service"
    sa_project = "" // defaults to the created project
  }]
}

resource "google_service_account_iam_member" "grant_gcp_compute_sa_roles_on_import_sa" {
  service_account_id = "import-service@${module.import-service-project.project_name}.gserviceaccount.com"
  member = "serviceAccount:${module.import-service-project.number}@cloudservices.gserviceaccount.com"
  role = "roles/iam.serviceAccountTokenCreator"
  description = "Give the GCP compute SA permission to send pubsub messages as the import service SA"
}
