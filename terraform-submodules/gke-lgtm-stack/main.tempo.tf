resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "lgtm-tempo"
  }
}

module "tempo_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.tempo
  service_account_name     = "tempo"
}

# resource "helm_release" "tempo" {
#   chart     = data.helm_template.tempo.chart
#   name      = data.helm_template.tempo.name
#   namespace = data.helm_template.tempo.namespace
#   values    = data.helm_template.tempo.values

#   timeout = 600
# }
data "helm_template" "tempo" {
  chart = "${path.module}/charts/tempo-distributed"

  name      = "tempo"
  namespace = kubernetes_namespace.tempo.metadata[0].name

  values = [
    templatefile("${path.module}/assets/tempo/values.yaml.tftpl", {
      tempo_service_account_name = module.tempo_service_account.kubernetes_service_account.metadata[0].name
    }),
    file("${path.module}/assets/tempo/resources.yaml"),
  ]
}
