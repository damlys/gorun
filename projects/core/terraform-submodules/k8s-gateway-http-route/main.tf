resource "kubernetes_manifest" "http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute" # https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.HTTPRoute
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = "gke-gateway"
        namespace   = "gke-gateway"
        sectionName = var.is_domain_root ? "https-root" : "https-wildcard"
      }]
      hostnames = [var.domain]
      rules = [{
        backendRefs = [{
          group     = ""
          kind      = "Service"
          name      = var.kubernetes_service.metadata[0].name
          namespace = var.kubernetes_service.metadata[0].namespace
          port      = var.service_port
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "health_check_policy" {
  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "HealthCheckPolicy" # https://googlecloudplatform.github.io/gke-gateway-api/#healthcheckpolicy
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
    }
    spec = {
      targetRef = {
        group     = ""
        kind      = "Service"
        name      = var.kubernetes_service.metadata[0].name
        namespace = var.kubernetes_service.metadata[0].namespace
      }
      default = {
        config = {
          type = "HTTP"
          httpHealthCheck = {
            port        = var.container_port
            requestPath = var.health_check_path
          }
        }
      }
    }
  }
}
