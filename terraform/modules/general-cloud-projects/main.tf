#######################################
### Google Cloud projects
#######################################

# data "google_billing_account" "" {
# }

# data "google_organization" "" {
# }

# data "google_folder" "" {
# }

module "general_project" {
  source = "../../submodules/gcp-project"

  id   = "gorun-general-2"
  name = "gorun-general"
}

module "dev_project" {
  source = "../../submodules/gcp-project"

  id   = "gorun-dev-2"
  name = "gorun-dev"
}

module "prod_project" {
  source = "../../submodules/gcp-project"

  id   = "gorun-prod-2"
  name = "gorun-prod"
}

#######################################
### Terraform state buckets
#######################################

resource "google_storage_bucket" "general_tfstate" {
  project       = module.general_project.id
  name          = "${module.general_project.id}-tfstate"
  location      = local.gcp_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
