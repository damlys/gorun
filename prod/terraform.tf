terraform {
  required_version = ">= 1.3.3, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.41.0, < 5.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.14.0, < 3.0.0"
    }
  }

  backend "gcs" {
    bucket = "damlys-terraform-state"
    prefix = "github.com/damlys/gorun/prod.tfstate"
  }
}

provider "google" {}

data "google_client_config" "kubernetes" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.kubernetes.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}
