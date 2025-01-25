resource "kubernetes_manifest" "httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      namespace = var.kubernetes_namespace.metadata[0].name
      name      = "kuard"
    }
    spec = {
      parentRefs = [{
        kind        = "Gateway"
        namespace   = "gke-gateway"
        name        = "gke-gateway"
        sectionName = "https"
      }]
      hostnames = [var.domain]
      rules = [{
        backendRefs = [{
          name = "kuard-http-server"
          port = 80
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "healthcheckpolicy" {
  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "HealthCheckPolicy"
    metadata = {
      namespace = var.kubernetes_namespace.metadata[0].name
      name      = "kuard"
    }
    spec = {
      targetRef = {
        group = ""
        kind  = "Service"
        name  = "kuard-http-server"
      }
      default = {
        config = {
          type = "HTTP"
          httpHealthCheck = {
            port        = 8080
            requestPath = "/healthy"
          }
        }
      }
    }
  }
}
