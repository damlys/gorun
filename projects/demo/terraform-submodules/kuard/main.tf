module "workspace" {
  source = "../../../core/terraform-submodules/k8s-workspace" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-workspace/0.5.100.zip"

  workspace_name = "kuard"

  iam_testers = [
    "user:damlys.test@gmail.com",
  ]
  iam_developers = [
  ]
}

module "helm_manifest" {
  source = "../helm-manifest" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/helm-manifest/0.5.100.zip"

  manifest = {
    apiVersion = "v1"
    kind       = "ResourceQuota"
    metadata = {
      name      = "pods"
      namespace = module.workspace.kubernetes_namespace.metadata[0].name
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
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.5.100.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = module.workspace.kubernetes_namespace
  service_account_name     = "stateless-kuard"
}

module "stateless_kuard_helm_template" {
  source = "../helm-template" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/helm-template/0.5.100.zip"

  repository = "../../helm-charts" # "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart      = "stateless-kuard"
  version_   = "0.5.100"
  name       = "stateless-kuard"
  namespace  = module.workspace.kubernetes_namespace.metadata[0].name

  values = [templatefile("${path.module}/assets/values.yaml.tftpl", {
    service_account_name = module.stateless_kuard_service_account.kubernetes_service_account.metadata[0].name

    example_username = data.kubernetes_secret.example.data.username
    example_password = data.kubernetes_secret.example.data.password
  })]
}

data "kubernetes_service" "stateless_kuard" {
  depends_on = [
    module.stateless_kuard_helm_template,
  ]

  metadata {
    name      = "stateless-kuard-http-server"
    namespace = module.workspace.kubernetes_namespace.metadata[0].name
  }
}

module "stateless_kuard_gateway_http_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-http-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.5.100.zip"

  kubernetes_service = data.kubernetes_service.stateless_kuard

  domain = "stateless-kuard.${var.platform_domain}"
}

module "stateless_kuard_availability_monitor" {
  source = "../../../o11y/terraform-submodules/gcp-availability-monitor" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/o11y/gcp-availability-monitor/0.5.100.zip"

  google_project = var.google_project

  request_host     = "stateless-kuard.${var.platform_domain}"
  request_path     = "/healthy"
  response_content = "ok"

  notification_emails = ["damlys.test@gmail.com"]
}

module "stateless_kuard_gateway_domain_redirect" {
  source = "../../../core/terraform-submodules/k8s-gateway-domain-redirect" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-domain-redirect/0.5.100.zip"

  kubernetes_namespace = module.workspace.kubernetes_namespace

  old_domain = "kuard.${var.platform_domain}"
  new_domain = "stateless-kuard.${var.platform_domain}"
}

#######################################
### stateful kuard
#######################################

module "stateful_kuard_service_account" {
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.5.100.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = module.workspace.kubernetes_namespace
  service_account_name     = "stateful-kuard"
}

resource "helm_release" "stateful_kuard" {
  repository = "../../helm-charts" # "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart      = "stateful-kuard"
  version    = "0.5.100"
  name       = "stateful-kuard"
  namespace  = module.workspace.kubernetes_namespace.metadata[0].name

  values = [templatefile("${path.module}/assets/values.yaml.tftpl", {
    service_account_name = module.stateful_kuard_service_account.kubernetes_service_account.metadata[0].name

    example_username = data.kubernetes_secret.example.data.username
    example_password = data.kubernetes_secret.example.data.password
  })]
}

data "kubernetes_service" "stateful_kuard" {
  depends_on = [
    helm_release.stateful_kuard,
  ]

  metadata {
    name      = "stateful-kuard-http-server-headless"
    namespace = module.workspace.kubernetes_namespace.metadata[0].name
  }
}

module "stateful_kuard_gateway_http_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-http-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.5.100.zip"

  kubernetes_service = data.kubernetes_service.stateful_kuard

  domain = "stateful-kuard.${var.platform_domain}"
}
