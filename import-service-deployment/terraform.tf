provider "google" {
  project = var.terraform_google_project
  region  = "us-central1"
  credentials = file("/var/secrets/atlantis-sa/atlantis-sa.json")
}

provider "google-beta" {
  project = var.terraform_google_project
  region  = "us-central1"
  credentials = file("/var/secrets/atlantis-sa/atlantis-sa.json")
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
  backend "gcs" {
    bucket = "dsp-tools-tf-state"
    path = "tfstate-managed/import-service"
    credentials = "/var/secrets/atlantis-sa/atlantis-sa.json"
  }
  required_version = ">= 0.12.19"
  required_providers {
    google = ">= 3.2.0"
    google-beta = ">= 3.2.0"
    vault = ">= 2.8.0"
  }
}
