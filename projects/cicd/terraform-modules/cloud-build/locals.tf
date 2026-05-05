locals {
  github_app_installation_id = 120316641 # https://github.com/settings/installations/120316641

  gcp_region = "europe-central2"
  gsa        = "service-${data.google_project.this.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com" # the Cloud Build Service Agent account

  devcontainer = "europe-central2-docker.pkg.dev/gogcp-main-8/private-docker-images/gorun/core/devcontainer:0.8.100"
}
