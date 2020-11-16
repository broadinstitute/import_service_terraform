#
# Vault Vars
#
variable "vault_addr" {
  default = "https://clotho.broadinstitute.org:8200"
}

variable "vault_path" {
  default = ""
}

variable "env" {}

variable "bucket_suffix" {}

variable "audience_domain" {}

variable "rawls_sa_email" {}

variable "sam_sa_email" {}

variable "terra_google_project" {
  description = "The google project that terra monolithic services run in"
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

variable "terraform_google_project" {}

#
# Firewall vars
#

variable "back_rawls_instance_name" {
  description = "Name of the back-rawls gce instance for an environment"
}

locals {
  back_rawls_instance_name = var.back_rawls_instance_name ? var.back_rawls_instance_name : "gce-rawls-${var.env}701"
}
