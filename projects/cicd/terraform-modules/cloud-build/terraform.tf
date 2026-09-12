terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0, < 7.0.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 8.0.0, < 9.0.0"
    }
  }

  backend "gcs" {
    bucket = "gogcp-main-9-terraform-state"
    prefix = "github.com/damlys/gorun/projects/cicd/terraform-modules/cloud-build"
  }
}
