resource "kubernetes_labels" "namespace" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = var.kubernetes_namespace.metadata[0].name
  }
  labels = {
    istio-injection = "disabled" # or "enabled"
  }

  force = true
}

#######################################
### stateless kuard
#######################################

module "stateless_kuard_service_account" {
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/core/gke-service-account/0.1.0.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = var.kubernetes_namespace
  service_account_name     = "stateless-kuard"
}

module "stateless_kuard_helm_release" {
  source = "../helm-release" # "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/kuard/helm-release/0.1.0.zip"

  # repository = "oci://europe-central2-docker.pkg.dev/gogke-main-0/private-helm-charts/gogke/kuard"
  chart = "../../helm-charts/stateless-kuard" # "stateless-kuard"
  # chart_version = "0.1.0"

  namespace = var.kubernetes_namespace.metadata[0].name
  name      = "stateless-kuard"
  values    = [templatefile("${path.module}/assets/values.yaml.tftpl", { service_account_name = module.stateless_kuard_service_account.kubernetes_service_account.metadata[0].name })]
}

data "kubernetes_service" "stateless_kuard" {
  depends_on = [
    module.stateless_kuard_helm_release,
  ]

  metadata {
    name      = "stateless-kuard-http-server"
    namespace = var.kubernetes_namespace.metadata[0].name
  }
}

module "stateless_kuard_gateway_route" {
  source = "../../../core/terraform-submodules/gke-gateway-route" # "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/core/gke-gateway-route/0.1.0.zip"

  kubernetes_service = data.kubernetes_service.stateless_kuard

  domain = "stateless-kuard.${var.platform_domain}"
}

module "stateless_kuard_availability_monitor" {
  source = "../../../o11y/terraform-submodules/gcp-availability-monitor" # "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/o11y/gcp-availability-monitor/0.1.0.zip"

  google_project = var.google_project

  request_host     = "stateless-kuard.${var.platform_domain}"
  request_path     = "/healthy"
  response_content = "ok"

  notification_emails = ["damlys.test@gmail.com"]
}

module "stateless_kuard_gateway_redirect" {
  source = "../../../core/terraform-submodules/gke-gateway-redirect" # "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/core/gke-gateway-redirect/0.1.0.zip"

  old_domain = "kuard.${var.platform_domain}"
  new_domain = "stateless-kuard.${var.platform_domain}"
}

#######################################
### stateful kuard
#######################################
