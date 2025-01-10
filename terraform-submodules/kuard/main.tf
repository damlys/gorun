module "service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = var.kubernetes_namespace
  service_account_name     = "kuard"
}

module "helm_release" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/helm-release/0.0.1.zip"

  # repository    = "oci://europe-central2-docker.pkg.dev/gogke-main-0/private-helm-charts/gogke"
  chart = "../../helm-charts/kuard" # "kuard"
  # chart_version = "0.0.2"

  namespace = var.kubernetes_namespace.metadata[0].name
  name      = "kuard"
  values    = [templatefile("${path.module}/assets/values.yaml.tftpl", { service_account_name = module.service_account.kubernetes_service_account.metadata[0].name })]
}

resource "kubernetes_manifest" "httproute" {
  depends_on = [
    module.helm_release,
  ]

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
        namespace   = "gateway"
        name        = "gateway"
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
  depends_on = [
    module.helm_release,
  ]

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

module "availability_monitor" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-availability-monitor/0.0.1.zip"

  google_project = var.google_project

  request_host     = var.domain
  request_path     = "/healthy"
  response_content = "ok"

  notification_emails = ["damlys.test@gmail.com"]
}
