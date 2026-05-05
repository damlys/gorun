provider "google" {
  project = "gogcp-test-7"
}

data "google_client_config" "oauth2" {
}

data "google_project" "this" {
}

data "google_container_cluster" "this" { # gke_gogcp-test-7_europe-central2-a_gogke-test-7
  location = "europe-central2-a"
  name     = "gogke-test-7"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.oauth2.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.this.endpoint}"
    token                  = data.google_client_config.oauth2.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
  }
  registries = [{
    url      = "oci://europe-central2-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.oauth2.access_token
  }]
}
