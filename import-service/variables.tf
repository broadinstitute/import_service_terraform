# See: https://github.com/hashicorp/terraform/issues/21418#issuecomment-495818852
variable dependencies {
  type        = any
  default     = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}

#
# General Vars
#
variable "env" {}

variable "bucket_suffix" {}

variable "audience_domain" {}

variable "rawls_sa_email" {}

variable "sam_sa_email" {}

variable "terra_google_project" {}

locals {
  rawls_import_pubsub_topic = "rawls-async-import-topic-${var.env}"
}

variable "import_service_google_project" {
  description = "The google project that import service will run in"
}

variable "import_service_google_project_folder_id" {
  description = "The folder ID for the import service project"
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the import service project"
}

variable "service" {
  description = "App name"
  default     = "importservice"
}

#
# Firewalls
#

# sourced from https://docs.google.com/document/d/1AzTX93P35r2alE4-pviPWf-1LRBWVAF-BwrYKVVpzWo/edit
variable "broad_range_cidrs" {
  type = list(string)
  default = ["69.173.64.0/19",
    "69.173.96.0/20",
    "69.173.112.0/21",
    "69.173.120.0/22",
    "69.173.124.0/23",
    "69.173.126.0/24",
    "69.173.127.0/25",
    "69.173.127.128/26",
    "69.173.127.192/27",
  "69.173.127.240/28"]
}

variable "back_rawls_instance" {
  type        = string
  description = "Name of the back-rawls gce instance for an environment"
}

# Pub/Sub doesn't publish their IP ranges, I found this on SO and verified experimentally:
# https://stackoverflow.com/a/51323548/2941784
variable "pubsub_ip_range" {
  type        = string
  description = "This is a work around for pub/sub not listing their ips publicly"
  default     = "2002:a00::/24"
}

variable "orchestration_instances" {
  type        = list(string)
  description = "A list of the names of each firecloud orchestration instance in a particular environment"
}

#
# Vault vars
#

variable "vault_root" {
  description = "Root path for import service secrets"
  default     = "secret/dsde/firecloud"
}

variable "vault_path" {
  description = "Vault path suffix for secrets in this deployment"
  default     = ""
}

locals {
  vault_path                    = var.vault_path == "" ? "${var.env}/import-service" : var.vault_path
  bucket_suffix                 = var.bucket_suffix == "" ? var.env : var.bucket_suffix
  import_service_google_project = var.import_service_google_project == "" ? "import-service-${var.env}" : var.import_service_google_project
}

#
# MySQL db vars
#
variable "mysql_user" {
  default = "isvc"
}

#
# Service Account Vars
#

# TODO: these could replace things in google-project.tf
variable "import_service_sa_roles" {
  default = [
    "roles/pubsub.admin",
    "roles/iam.serviceAccountTokenCreator"
  ]
  description = "Roles to give the import service SA in import_service_google_project"
}
variable "gcp_compute_sa_roles_on_import_sa" {
  default = [
    "roles/iam.serviceAccountTokenCreator"
  ]
  description = "Roles to give the GCP compute SA on the import service SA"
}
