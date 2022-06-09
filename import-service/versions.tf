terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
    http = {
      source = "hashicorp/http"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
  required_version = ">= 0.13"
}
