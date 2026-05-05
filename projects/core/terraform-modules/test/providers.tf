provider "google" {
  project = "gogcp-test-8"
}

data "google_client_config" "oauth2" {
}

data "google_project" "this" {
}

# module.test_platform.google_container_cluster == gke_gogcp-test-8_europe-central2-a_gogke-test-8

provider "kubernetes" {
  host                   = "https://${module.test_platform.google_container_cluster.endpoint}"
  token                  = data.google_client_config.oauth2.access_token
  cluster_ca_certificate = base64decode(module.test_platform.google_container_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = "https://${module.test_platform.google_container_cluster.endpoint}"
    token                  = data.google_client_config.oauth2.access_token
    cluster_ca_certificate = base64decode(module.test_platform.google_container_cluster.master_auth[0].cluster_ca_certificate)
  }
  registries = [{
    url      = "oci://europe-central2-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.oauth2.access_token
  }]
}
