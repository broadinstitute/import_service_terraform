provider "google" {
  region  = "us-central1"
}

provider "google-beta" {
  region  = "us-central1"
}

provider "vault" {
  address = var.vault_addr
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id = var.approle_role_id
      secret_id = var.approle_secret_id
    }
  }
}

terraform {
  required_version = ">= 0.12.19"
  required_providers {
    google = ">= 3.2.0"
    google-beta = ">= 3.2.0"
    vault = ">= 2.8.0"
  }
}
