# Custom IAM role to be used by the deployer SA. This custom role allows creating/updating cloud scheduler
# jobs during App Engine deployment via cron.yaml.
resource "google_project_iam_custom_role" "cloud-scheduler-appengine-custom-role" {
  project     = local.import_service_google_project
  role_id     = "appEngineDeploymentEnabler"
  title       = "App Engine Deployment Enabler"
  description = "Additional permissions needed to deploy and enable new App Engine versions. Allows creation of Cloud Scheduler schedules and routing of traffic to the new version."
  permissions = ["appengine.services.update", "appengine.versions.update",
                  "cloudscheduler.jobs.create", "cloudscheduler.jobs.delete", "cloudscheduler.jobs.enable",
                  "cloudscheduler.jobs.fullView", "cloudscheduler.jobs.get", "cloudscheduler.jobs.list",
                  "cloudscheduler.jobs.update", "cloudscheduler.locations.get", "cloudscheduler.locations.list"]
}

# key-rotation policy for service accounts
# note this requires the terraform to be run regularly
resource "time_rotating" "sa_key_rotation_policy" {
  rotation_days = 75 # compliance requirement: 90 days
}

# create deployer SA
resource "google_service_account" "sa_deployer" {
  account_id   = "deployer"
  display_name = "deployer"
  description  = "Used to deploy code to App Engine"
  project      = local.import_service_google_project
}

# create key for deployer SA, pointing at rotation policy
resource "google_service_account_key" "sa_key_deployer" {
  service_account_id = google_service_account.sa_deployer.name
  keepers = {
    rotation_time = time_rotating.sa_key_rotation_policy.rotation_rfc3339
  }
}

# TODO: uncomment when ready to handle the import-service SA outside of terraform-modules
# create import-service SA
# resource "google_service_account" "sa_import-service" {
#   account_id   = "import-service"
#   display_name = "import-service"
#   description  = "Used within the Import Service GAE app and by BEEs to run the app"
#   project      = local.import_service_google_project
# }

# TODO: uncomment when ready to handle the import-service SA outside of terraform-modules
# create key for import-service SA, pointing at rotation policy
# ** only create the key in qa and dev ** since the key is only needed for BEEs
# resource "google_service_account_key" "sa_key_import-service" {
#   count = var.env == "qa" || var.env == "dev" ? 1 : 0
#   service_account_id = google_service_account.sa_import-service.name
#   keepers = {
#     rotation_time = time_rotating.sa_key_rotation_policy.rotation_rfc3339
#   }
# }

# N.B we save the keys for deployer and import-service SAs to Vault in vault.tf, not here

module "import-service-project" {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/google-project?ref=google-project-1.0.0"
  providers = {
    google.target = google
  }
  project_name = local.import_service_google_project
  folder_id = var.import_service_google_project_folder_id
  billing_account_id = var.billing_account_id
  apis_to_enable = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "appengine.googleapis.com",
    "cloudbuild.googleapis.com",
    "pubsub.googleapis.com",
    "storage-component.googleapis.com",
    "iamcredentials.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudscheduler.googleapis.com",
    "containerscanning.googleapis.com"
  ]

  // TODO: delete when ready to handle the import-service SA outside of terraform-modules
  service_accounts_to_create_with_keys = [
    {
      sa_name = "import-service"
      key_vault_path = "${var.vault_root}/${local.vault_path}/import-service-account.json"
    }
  ]

  roles_to_grant_by_email_and_type = [{
    email = local.terraform_sa_email
    role = "roles/iam.serviceAccountTokenCreator"
    id_type = local.terraform_sa_email_is_sa ? "serviceAccount" : "user"
  }]

  service_accounts_to_grant_by_name_and_project = [{
    sa_role = "roles/pubsub.editor"
    sa_name = "import-service"
    sa_project = "" // defaults to the created project
  },{
    sa_role = "roles/iam.serviceAccountTokenCreator"
    sa_name = "import-service"
    sa_project = "" // defaults to the created project
  },{
    sa_role = "roles/appengine.deployer"
    sa_name = "deployer"
    sa_project = "" // defaults to the created project
  },{
    sa_role = "roles/cloudbuild.builds.builder"
    sa_name = "deployer"
    sa_project = "" // defaults to the created project
  },{
    # Note that custom roles must be of the format [projects|organizations]/{parent-name}/roles/{role-name}.
    sa_role = "projects/${module.import-service-project.project_name}/roles/${google_project_iam_custom_role.cloud-scheduler-appengine-custom-role.role_id}"
    sa_name = "deployer"
    sa_project = "" // defaults to the created project
  }]
}

locals {
  import_service_sa_email = "import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
}

# Give the GCP pubsub SA permission to impersonate the import service SA, which it will use to send pubsub messages as the import service SA
resource "google_service_account_iam_member" "grant_gcp_compute_sa_roles_on_import_sa" {
  service_account_id = "projects/${module.import-service-project.project_name}/serviceAccounts/${local.import_service_sa_email}"
  member = "serviceAccount:service-${module.import-service-project.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role = "roles/iam.serviceAccountTokenCreator"
  depends_on = [module.import-service-project]
}

# This next section is about granting the Terraform SA permission to impersonate the import service SA. This is needed
# to reference the import service SA with Sam. There's no way I can find of getting the Terraform SA email address,
# so we take their token, pass it to Google's tokeninfo, and extract it from there.
data "google_client_config" "terraform_sa" {}

data "http" "terraform_sa_tokeninfo" {
  url = "https://oauth2.googleapis.com/tokeninfo?access_token=${data.google_client_config.terraform_sa.access_token}"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  terraform_sa_email = jsondecode(data.http.terraform_sa_tokeninfo.body)["email"]
  terraform_sa_email_is_sa = length(regexall("\\.gserviceaccount\\.com$", local.terraform_sa_email)) > 0
}

resource "google_service_account_iam_member" "grant_self_token_creator_on_import_sa" {
  service_account_id = "projects/${module.import-service-project.project_name}/serviceAccounts/${local.import_service_sa_email}"
  member = local.terraform_sa_email_is_sa ? "serviceAccount:${local.terraform_sa_email}" : "user:${local.terraform_sa_email}"
  role = "roles/iam.serviceAccountTokenCreator"
  depends_on = [module.import-service-project]
}

resource "google_service_account_iam_member" "grant_appengine_token_creator_on_import_sa" {
  service_account_id = "projects/${module.import-service-project.project_name}/serviceAccounts/${local.import_service_sa_email}"
  member = "serviceAccount:${module.import-service-project.project_name}@appspot.gserviceaccount.com"
  role = "roles/iam.serviceAccountTokenCreator"
  depends_on = [module.import-service-project, google_app_engine_application.gae_import_service]
}

# Google IAM is a bit "eventually" so add a sleep between granting token creator and retrieving the token.
resource "null_resource" "delay_before_getting_import_service_token" {
  depends_on = [google_service_account_iam_member.grant_self_token_creator_on_import_sa]
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# NOTE: It is possible that you will get a 403 here if the previous delay wasn't long enough.
# If this happens, just rerun the terraform apply step and it should work.
data "google_service_account_access_token" "import_service_token" {
  depends_on = [null_resource.delay_before_getting_import_service_token]
  provider               = google
  target_service_account = local.import_service_sa_email
  scopes                 = ["https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/userinfo.email"]
  lifetime               = "300s"
}
