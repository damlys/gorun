terraform {
  required_version = ">= 1.9.6, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.3.0, < 7.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0, < 3.0.0"
    }
  }

  backend "gcs" {
    bucket = "gogcp-main-3-terraform-state"
    prefix = "github.com/damlys/gorun/projects/o11y/terraform-modules/test"
  }
}
