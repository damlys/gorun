terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 8.0.0, < 9.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0, < 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0.0, < 4.0.0"
    }
  }

  backend "gcs" {
    bucket = "gogcp-main-9-terraform-state"
    prefix = "github.com/damlys/gorun/projects/core/terraform-modules/test"
  }
}
