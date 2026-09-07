module "workspace" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-workspace/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-workspace"

  workspace_name = "kuard"

  iam_testers = [
    "user:damlys.test@gmail.com",
  ]
  iam_developers = [
  ]
}

#######################################
### stateless kuard
#######################################

module "stateless_kuard_service_account" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gke-service-account/0.9.100.zip"
  source = "../../../core/terraform-submodules/gke-service-account"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = module.workspace.kubernetes_namespace
  service_account_name     = "stateless-kuard"
}

resource "helm_release" "stateless_kuard" {
  # PROD -dependency_update
  dependency_update = true

  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/demo"
  repository = "../../helm-charts"
  chart      = "stateless-kuard"
  version    = "0.9.100"
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
    helm_release.stateless_kuard,
  ]

  metadata {
    name      = "stateless-kuard-http-server"
    namespace = module.workspace.kubernetes_namespace.metadata[0].name
  }
}

module "stateless_kuard_gateway_http_route" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = data.kubernetes_service.stateless_kuard

  domain = "stateless-kuard.${var.platform_domain}"
}

module "stateless_kuard_gateway_domain_redirect" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-domain-redirect/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-domain-redirect"

  kubernetes_namespace = module.workspace.kubernetes_namespace

  old_domain = "kuard.${var.platform_domain}"
  new_domain = "stateless-kuard.${var.platform_domain}"
}

#######################################
### stateful kuard
#######################################

module "stateful_kuard_service_account" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gke-service-account/0.9.100.zip"
  source = "../../../core/terraform-submodules/gke-service-account"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = module.workspace.kubernetes_namespace
  service_account_name     = "stateful-kuard"
}

resource "helm_release" "stateful_kuard" {
  # PROD -dependency_update
  dependency_update = true

  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/demo"
  repository = "../../helm-charts"
  chart      = "stateful-kuard"
  version    = "0.9.100"
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
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = data.kubernetes_service.stateful_kuard

  domain = "stateful-kuard.${var.platform_domain}"
}
