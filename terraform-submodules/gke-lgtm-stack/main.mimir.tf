resource "kubernetes_namespace" "mimir" {
  metadata {
    name = "lgtm-mimir"
  }
}

module "mimir_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.mimir
  service_account_name     = "mimir"
}

data "helm_template" "mimir" {
  chart = "${path.module}/charts/mimir-distributed"

  name      = "mimir"
  namespace = kubernetes_namespace.mimir.metadata[0].name

  values = [
    file("${path.module}/charts/mimir-distributed/small.yaml"),
    templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
      mimir_service_account_name = module.mimir_service_account.kubernetes_service_account.metadata[0].name
    }),
    file("${path.module}/assets/mimir/resources.yaml"),
  ]
}
# resource "helm_release" "mimir" {
#   chart     = data.helm_template.mimir.chart
#   name      = data.helm_template.mimir.name
#   namespace = data.helm_template.mimir.namespace
#   values    = data.helm_template.mimir.values

#   timeout = 900
# }
