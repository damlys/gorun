locals {
  gcp_region = "europe-central2"
  gsa        = "service-${data.google_project.this.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com" # the Cloud Build Service Agent account

  cloud_build_connection_name   = "github"
  cloud_build_connection_domain = "github.com"
  cloud_build_envs = {
    DOCKERHUB_USERNAME = "damlys"
  }
  cloud_build_secret_envs = {
    DOCKERHUB_TOKEN = "latest"
  }

  devcontainer = "europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images/gorun/core/devcontainer:0.9.100"
}
