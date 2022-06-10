terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      configuration_aliases = [
        google.target,
      ]
    }
    google-beta = {
      source = "hashicorp/google-beta"
      configuration_aliases = [
        google-beta.target,
      ]
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
  required_version = ">= 1.0"
}
