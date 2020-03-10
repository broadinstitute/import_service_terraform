variable "terraform_google_project" {}

#
# Vault Vars
#
variable "vault_addr" {
  default = "https://clotho.broadinstitute.org:8200"
}
variable "approle_role_id" {
  description = "Vault approle role ID"
}
variable "approle_secret_id" {
  description = "Vault approle secret ID"
}
