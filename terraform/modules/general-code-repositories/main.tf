#######################################
### GitHub Actions OIDC
#######################################

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = google_iam_workload_identity_pool.github.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.aud"        = "assertion.aud"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
}

#######################################
### SOPS encryption key ring
#######################################

resource "google_kms_key_ring" "sops" {
  name     = "sops"
  location = local.gcp_region
}

#######################################
### GitHub repositories
#######################################

# data "github_organization" "" {
# }

module "gorun_repository" {
  source = "../../submodules/gh-repository"

  google_iam_workload_identity_pool = google_iam_workload_identity_pool.github
  google_kms_key_ring               = google_kms_key_ring.sops

  owner = "damlys"
  name  = "gorun"
}

module "gomod_repository" {
  source = "../../submodules/gh-repository"

  google_iam_workload_identity_pool = google_iam_workload_identity_pool.github
  google_kms_key_ring               = google_kms_key_ring.sops

  owner = "damlys"
  name  = "gomod"
}
