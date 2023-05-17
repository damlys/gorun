terraform {
  required_version = ">= 1.4.5, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.63.0, < 5.0.0"
    }
  }

  backend "gcs" {
    bucket = "gorun-general-2-tfstate"
    prefix = "github.com/damlys/gorun/terraform/modules/general-cloud-projects/terraform.tfstate"
  }
}
