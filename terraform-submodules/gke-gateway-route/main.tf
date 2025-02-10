#######################################
### Kubernetes gateway
#######################################

resource "kubernetes_manifest" "http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute" # https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.HTTPRoute
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
      labels    = var.kubernetes_service.metadata[0].labels
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = "gke-gateway"
        namespace   = "gke-gateway"
        sectionName = "https"
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
      labels    = var.kubernetes_service.metadata[0].labels
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

#######################################
### Google backend
#######################################

data "kubernetes_namespace" "gke_gateway" {
  metadata {
    name = "gke-gateway"
  }
}

data "kubernetes_resource" "gke_gateway" {
  depends_on = [
    kubernetes_manifest.http_route,
    kubernetes_manifest.health_check_policy,
  ]

  api_version = "gateway.networking.k8s.io/v1"
  kind        = "Gateway"
  metadata {
    namespace = data.kubernetes_namespace.gke_gateway.metadata[0].name
    name      = "gke-gateway"
  }
}

# apiVersion: gateway.networking.k8s.io/v1
# kind: Gateway
# metadata:
#   annotations:
#     networking.gke.io/backend-services: /projects/764086219165/global/backendServices/gkegw1-rxra-gke-gateway-gw-serve404-80-gvlt3glsl26m,
#       /projects/764086219165/global/backendServices/gkegw1-rxra-gke-gateway-gw-serve500-80-fmyxz1sppcau,
#       /projects/764086219165/global/backendServices/gkegw1-rxra-kuar-demo-kuard-http-server-80-v49bg5xn0q9o,
#       /projects/764086219165/global/backendServices/gkegw1-rxra-lgtm-grafana-grafana-80-3y1pnm1bpt5z
locals {
  x1                   = data.kubernetes_resource.gke_gateway.object.metadata.annotations["networking.gke.io/backend-services"]
  x2                   = split(",", local.x1)
  x3                   = [for v in local.x2 : trimspace(v)]
  x4                   = [for v in local.x3 : reverse(split("/", v))[0]]
  x5                   = [for v in local.x4 : v if strcontains(v, "${var.kubernetes_service.metadata[0].namespace}-${var.kubernetes_service.metadata[0].name}-${var.service_port}")]
  backend_service_name = local.x5[0]
}

data "google_compute_backend_service" "this" {
  project = var.google_project.project_id
  name    = local.backend_service_name
}

#######################################
### Google IAP
#######################################
