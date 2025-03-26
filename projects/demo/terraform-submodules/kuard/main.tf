resource "kubernetes_labels" "namespace" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = var.kubernetes_namespace.metadata[0].name
  }
  labels = {
    istio-injection = "enabled" # or "disabled"
  }

  force = true
}

module "helm_manifest" {
  source = "../helm-manifest" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/helm-manifest/0.2.100.zip"

  manifest = {
    apiVersion = "v1"
    kind       = "ResourceQuota"
    metadata = {
      name      = "pods"
      namespace = var.kubernetes_namespace.metadata[0].name
    }
    spec = {
      hard = {
        pods = 4
      }
    }
  }
}

#######################################
### stateless kuard
#######################################

module "stateless_kuard_service_account" {
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = var.kubernetes_namespace
  service_account_name     = "stateless-kuard"
}

module "stateless_kuard_helm_template" {
  source = "../helm-template" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/helm-template/0.2.100.zip"

  repository = "../../helm-charts" # "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart      = "stateless-kuard"
  version_   = "0.2.100"
  name       = "stateless-kuard"
  namespace  = var.kubernetes_namespace.metadata[0].name

  values = [templatefile("${path.module}/assets/values.yaml.tftpl", {
    service_account_name = module.stateless_kuard_service_account.kubernetes_service_account.metadata[0].name
  })]
}

data "kubernetes_service" "stateless_kuard" {
  depends_on = [
    module.stateless_kuard_helm_template,
  ]

  metadata {
    name      = "stateless-kuard-http-server"
    namespace = var.kubernetes_namespace.metadata[0].name
  }
}

module "stateless_kuard_gateway_route" {
  source = "../../../core/terraform-submodules/gke-gateway-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-gateway-route/0.2.100.zip"

  kubernetes_service = data.kubernetes_service.stateless_kuard

  domain = "stateless-kuard.${var.platform_domain}"
}

module "stateless_kuard_availability_monitor" {
  source = "../../../o11y/terraform-submodules/gcp-availability-monitor" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/o11y/gcp-availability-monitor/0.2.100.zip"

  google_project = var.google_project

  request_host     = "stateless-kuard.${var.platform_domain}"
  request_path     = "/healthy"
  response_content = "ok"

  notification_emails = ["damlys.test@gmail.com"]
}

module "stateless_kuard_gateway_redirect" {
  source = "../../../core/terraform-submodules/gke-gateway-redirect" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-gateway-redirect/0.2.100.zip"

  kubernetes_namespace = var.kubernetes_namespace

  old_domain = "kuard.${var.platform_domain}"
  new_domain = "stateless-kuard.${var.platform_domain}"
}

#######################################
### stateful kuard
#######################################

module "stateful_kuard_service_account" {
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = var.kubernetes_namespace
  service_account_name     = "stateful-kuard"
}

resource "helm_release" "stateful_kuard" {
  repository = "../../helm-charts" # "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart      = "stateful-kuard"
  version    = "0.2.100"
  name       = "stateful-kuard"
  namespace  = var.kubernetes_namespace.metadata[0].name

  values = [templatefile("${path.module}/assets/values.yaml.tftpl", {
    service_account_name = module.stateful_kuard_service_account.kubernetes_service_account.metadata[0].name
  })]
}

data "kubernetes_service" "stateful_kuard" {
  depends_on = [
    helm_release.stateful_kuard,
  ]

  metadata {
    name      = "stateful-kuard-http-server-headless"
    namespace = var.kubernetes_namespace.metadata[0].name
  }
}

module "stateful_kuard_gateway_route" {
  source = "../../../core/terraform-submodules/gke-gateway-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-gateway-route/0.2.100.zip"

  kubernetes_service = data.kubernetes_service.stateful_kuard

  domain = "stateful-kuard.${var.platform_domain}"
}
