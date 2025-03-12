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

module "stateless_kuard_helm_release" {
  source = "../helm-release" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/helm-release/0.2.100.zip"

  # repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart = "../../helm-charts/stateless-kuard" # "stateless-kuard"
  # chart_version = "0.2.100"

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
  # repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts/gorun/demo"
  chart = "../../helm-charts/stateful-kuard" # "stateful-kuard"
  # version = "0.2.100"

  namespace = var.kubernetes_namespace.metadata[0].name
  name      = "stateful-kuard"
  values    = [templatefile("${path.module}/assets/values.yaml.tftpl", { service_account_name = module.stateful_kuard_service_account.kubernetes_service_account.metadata[0].name })]
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

resource "kubernetes_manifest" "stateful_kuard_istio_request_authentication" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "RequestAuthentication" # https://istio.io/latest/docs/reference/config/security/request_authentication/
    metadata = {
      name      = data.kubernetes_service.stateful_kuard.metadata[0].name
      namespace = data.kubernetes_service.stateful_kuard.metadata[0].namespace
    }
    spec = {
      selector = { matchLabels = data.kubernetes_service.stateful_kuard.spec[0].selector }

      jwtRules = [
        {
          issuer  = "https://accounts.google.com"
          jwksUri = "https://www.googleapis.com/oauth2/v3/certs"

          forwardOriginalToken = true
          outputClaimToHeaders = [
            {
              claim  = "email"
              header = "X-Forwarded-Email"
            },
            {
              claim  = "sub"
              header = "X-Forwarded-User"
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "stateful_kuard_istio_authorization_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy" # https://istio.io/latest/docs/reference/config/security/authorization-policy/
    metadata = {
      name      = data.kubernetes_service.stateful_kuard.metadata[0].name
      namespace = data.kubernetes_service.stateful_kuard.metadata[0].namespace
    }
    spec = {
      selector = { matchLabels = data.kubernetes_service.stateful_kuard.spec[0].selector }

      action = "ALLOW"
      rules = [
        {
          from = [{
            source = {
              requestPrincipals = ["https://accounts.google.com/*"]
            }
          }]
        },
        { # unprotected paths
          to = [{
            operation = {
              paths = [
                "/_healthy",
                "/_healthz",
                "/-/healthy",
                "/-/healthz",
                "/api/healthy",
                "/api/healthz",
                "/healthy",
                "/healthz",
              ]
            }
          }]
        },
      ]
    }
  }
}
