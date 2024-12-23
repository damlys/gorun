data "kubernetes_namespace" "this" {
  metadata {
    name = "kuar-demo"
  }
}

resource "kubernetes_resource_quota" "pods" {
  metadata {
    namespace = data.kubernetes_namespace.this.metadata[0].name
    name      = "pods"
  }
  spec {
    hard = {
      pods = 3
    }
  }
}

module "service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this
  kubernetes_namespace     = data.kubernetes_namespace.this
  service_account_name     = "kuard"
}

module "this" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/kuard/0.0.2.zip"

  kubernetes_namespace       = data.kubernetes_namespace.this
  kubernetes_service_account = module.service_account.kubernetes_service_account
}

resource "kubernetes_manifest" "httproute" {
  depends_on = [
    module.this,
  ]

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      namespace = data.kubernetes_namespace.this.metadata[0].name
      name      = "kuard"
    }
    spec = {
      parentRefs = [{
        kind        = "Gateway"
        namespace   = "gateway"
        name        = "gateway"
        sectionName = "https"
      }]
      hostnames = ["kuard.gogke-test-7.damlys.pl"]
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
  depends_on = [
    module.this,
  ]

  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "HealthCheckPolicy"
    metadata = {
      namespace = data.kubernetes_namespace.this.metadata[0].name
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
