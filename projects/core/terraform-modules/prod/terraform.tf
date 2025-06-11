terraform {
  required_version = ">= 1.9.6, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.3.0, < 7.0.0"
    }
  }

  backend "gcs" {
    bucket = "gogcp-main-3-terraform-state"
    prefix = "github.com/damlys/gorun/projects/core/terraform-modules/prod"
  }
}
