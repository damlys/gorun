provider "google" {
  project = "gorun-dev-2"
}

data "google_client_config" "oauth2" {
}

data "google_project" "this" {
}

data "google_container_cluster" "this" { # gke_gorun-dev-2_europe-central2-a_dev
  location = "europe-central2-a"
  name     = "dev"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.oauth2.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.this.endpoint}"
    token                  = data.google_client_config.oauth2.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
  }
  registry {
    url = "oci://europe-central2-docker.pkg.dev/gorun-general-2/private-helm-charts"

    username = "oauth2accesstoken"
    password = data.google_client_config.oauth2.access_token
  }
  registry {
    url = "oci://europe-central2-docker.pkg.dev/gorun-general-2/public-helm-charts"
  }
}
