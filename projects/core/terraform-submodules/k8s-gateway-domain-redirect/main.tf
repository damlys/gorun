resource "kubernetes_manifest" "http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "redirect-domain-${join("-", reverse(split(".", var.old_domain)))}"
      namespace = var.kubernetes_namespace.metadata[0].name
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = "gke-gateway"
        namespace   = "gke-gateway"
        sectionName = "https-wildcard"
      }]
      hostnames = [var.old_domain]
      rules = [{
        filters = [{
          type = "RequestRedirect"
          requestRedirect = {
            hostname   = var.new_domain
            statusCode = var.status_code
          }
        }]
      }]
    }
  }
}
