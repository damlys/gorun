provider "kubernetes" {
  host                   = "https://${google_container_cluster.this.endpoint}"
  token                  = var.google_client_config.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.this.endpoint}"
    token                  = var.google_client_config.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
  }
  registry {
    url      = "oci://europe-central2-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = var.google_client_config.access_token
  }
}
