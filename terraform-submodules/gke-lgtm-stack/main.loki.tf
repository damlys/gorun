resource "kubernetes_namespace" "loki" {
  metadata {
    name = "lgtm-loki"
  }
}

module "loki_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.loki
  service_account_name     = "loki"
}

# resource "helm_release" "loki" {
#   chart     = data.helm_template.loki.chart
#   name      = data.helm_template.loki.name
#   namespace = data.helm_template.loki.namespace
#   values    = data.helm_template.loki.values

#   timeout = 600
# }
data "helm_template" "loki" {
  chart = "${path.module}/charts/loki"

  name      = "loki"
  namespace = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/charts/loki/single-binary-values.yaml"),
    templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
      loki_service_account_name = module.loki_service_account.kubernetes_service_account.metadata[0].name
    }),
    file("${path.module}/assets/loki/resources.yaml"),
  ]
}
