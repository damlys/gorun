resource "google_project_service" "iap" {
  project = var.google_project.project_id
  service = "iap.googleapis.com"
}

resource "google_iap_brand" "this" { # console.cloud.google.com/apis/credentials/consent (OAuth consent screen)
  project           = var.google_project.project_id
  application_title = var.google_project.project_id
  support_email     = "damlys.test@gmail.com"
}

resource "google_iap_client" "this" { # console.cloud.google.com/apis/credentials (OAuth 2.0 Client IDs)
  brand        = google_iap_brand.this.name
  display_name = var.domain
}

resource "kubernetes_secret" "iap_client" {
  metadata {
    name      = "${var.kubernetes_service.metadata[0].name}-iap-client"
    namespace = var.kubernetes_service.metadata[0].namespace
    labels    = var.kubernetes_service.metadata[0].labels
  }
  data = {
    key = google_iap_client.this.secret
  }
}

resource "kubernetes_manifest" "gcp_backend_policy" {
  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "GCPBackendPolicy" # https://googlecloudplatform.github.io/gke-gateway-api/#gcpbackendpolicy
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
        iap = {
          enabled            = var.iap_enabled
          clientID           = google_iap_client.this.client_id
          oauth2ClientSecret = { name = kubernetes_secret.iap_client.metadata[0].name }
        }
      }
    }
  }
}
