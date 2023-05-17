terraform {
  required_version = ">= 1.4.5, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.63.0, < 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0, < 3.0.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }

  backend "gcs" {
    bucket = "gorun-general-2-tfstate"
    prefix = "github.com/damlys/gorun/terraform/modules/dev-environment/terraform.tfstate"
  }
}
