terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.0.0, < 6.0.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}
