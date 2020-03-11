#
# Vault Vars
#
variable "vault_addr" {
  default = "https://clotho.broadinstitute.org:8200"
}

variable "env" {}

variable "audience_domain" {}

variable "rawls_sa_email" {}

variable "import_service_google_project" {
  description = "The google project that import service will run in"
}

variable "import_service_google_project_folder_id" {
  description = "The folder ID for the import service project"
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the import service project"
}

variable "owner" {
  description = "Environment or developer"
}

variable "terraform_google_project" {}