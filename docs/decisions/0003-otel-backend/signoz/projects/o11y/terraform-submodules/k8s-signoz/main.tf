resource "kubernetes_namespace" "signoz" {
  metadata {
    name = "o11y-signoz"
  }

  timeouts {
    delete = "20m"
  }
}

resource "helm_release" "signoz" {
  repository = "${path.module}/helm/charts"
  chart      = "signoz"
  name       = "signoz"
  namespace  = kubernetes_namespace.signoz.metadata[0].name

  values = [
    file("${path.module}/helm/values/signoz.yaml"),
    templatefile("${path.module}/assets/signoz.yaml.tftpl", {
    }),
  ]

  lifecycle {
    prevent_destroy = true
  }
}

data "kubernetes_service" "signoz" {
  metadata {
    name      = helm_release.signoz.metadata.name
    namespace = helm_release.signoz.metadata.namespace
  }
}

module "signoz_gateway_http_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-http-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.3.100.zip"

  kubernetes_service = data.kubernetes_service.signoz

  domain            = var.signoz_domain
  service_port      = 8080
  container_port    = 8080
  health_check_path = "/api/v1/health"
}
