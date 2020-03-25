#
# Vault Vars
#
variable "vault_addr" {
  default = "https://clotho.broadinstitute.org:8200"
}

variable "vault_path" {
  default = var.env
}

variable "env" {}

variable "bucket_suffix" {}

variable "audience_domain" {}

variable "rawls_sa_email" {}

variable "sam_sa_email" {}

variable "terra_google_project" {
  description = "The google project that terra monolithic services run in"
  default = ""
}

variable "import_service_google_project" {
  description = "The google project that import service will run in"
  default = ""
}

locals  {
  terra_google_project = var.terra_google_project == "" ? "broad-dsde-${var.env}" : var.terra_google_project
  import_service_google_project = var.import_service_google_project == "" ? "terra-importservice-${var.env}" ? var.import_service_google_project
  bucket_suffix = var.bucket_suffix == "" ? var.env : var.bucket_suffix
}

variable "import_service_google_project_folder_id" {
  description = "The folder ID for the import service project"
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the import service project"
}

variable "terraform_google_project" {}