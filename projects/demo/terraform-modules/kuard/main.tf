resource "kubernetes_resource_quota" "pods" {
  metadata {
    namespace = data.kubernetes_namespace.this.metadata[0].name
    name      = "pods"
  }
  spec {
    hard = {
      pods = 4
    }
  }
}

module "this" {
  source = "../../terraform-submodules/kuard" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/kuard/0.2.100.zip"

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this
  kubernetes_namespace     = data.kubernetes_namespace.this

  platform_domain = "gogke-test-2.damlys.pl"
}
