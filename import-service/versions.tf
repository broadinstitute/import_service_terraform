terraform {
  required_providers {
    google = {
      source = "registry.terraform.io/hashicorp/google"
    }
    google-beta = {
      source = "registry.terraform.io/hashicorp/google-beta"
    }
    http = {
      source = "registry.terraform.io/hashicorp/http"
    }
    null = {
      source = "registry.terraform.io/hashicorp/null"
    }
    random = {
      source = "registry.terraform.io/hashicorp/random"
    }
    vault = {
      source = "registry.terraform.io/hashicorp/vault"
    }
  }
  required_version = ">= 0.13"
}
