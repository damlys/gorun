resource "kubernetes_namespace" "clickstack" {
  metadata {
    name = "o11y-clickstack"
  }

  timeouts {
    delete = "20m"
  }
}

resource "helm_release" "clickstack" {
  repository = "${path.module}/helm/charts"
  chart      = "clickstack"
  name       = "clickstack"
  namespace  = kubernetes_namespace.clickstack.metadata[0].name

  values = [
    file("${path.module}/helm/values/clickstack.yaml"),
    templatefile("${path.module}/assets/clickstack.yaml.tftpl", {
      name      = "clickstack"
      namespace = kubernetes_namespace.clickstack.metadata[0].name

      hyperdx_domain = var.hyperdx_domain
    }),
  ]

  lifecycle {
    prevent_destroy = true
  }
}

data "kubernetes_service" "hyperdx" {
  metadata {
    name      = "${helm_release.clickstack.metadata.name}-app"
    namespace = helm_release.clickstack.metadata.namespace
  }
}

module "hyperdx_gateway_http_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-http-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.3.100.zip"

  kubernetes_service = data.kubernetes_service.hyperdx

  domain            = var.hyperdx_domain
  service_port      = 3000
  container_port    = 3000
  health_check_path = "/api/health"
}

module "hyperdx_availability_monitor" {
  source = "../gcp-availability-monitor" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/gcp-availability-monitor/0.7.100.zip"

  google_project = var.google_project

  request_host     = var.hyperdx_domain
  request_path     = "/api/health"
  response_content = "{\"data\":\"OK\"" # without closing curly brace

  notification_emails = ["damlys.test@gmail.com"]
}
