#######################################
### Loki
#######################################

resource "kubernetes_namespace" "loki" {
  metadata {
    name = "lgtm-loki"
  }
}

module "loki_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.loki
  service_account_name     = "loki"
}

resource "helm_release" "loki" {
  chart = "${path.module}/charts/loki"

  name      = "loki"
  namespace = kubernetes_namespace.loki.metadata[0].name

  values = [
    templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
      loki_service_account_name = module.loki_service_account.kubernetes_service_account.metadata[0].name
    }),
  ]
}

#######################################
### Mimir
#######################################

resource "kubernetes_namespace" "mimir" {
  metadata {
    name = "lgtm-mimir"
  }
}

module "mimir_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.mimir
  service_account_name     = "mimir"
}

resource "helm_release" "mimir" {
  chart = "${path.module}/charts/mimir-distributed"

  name      = "mimir"
  namespace = kubernetes_namespace.mimir.metadata[0].name

  values = [
    templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
      mimir_service_account_name = module.mimir_service_account.kubernetes_service_account.metadata[0].name
    }),
  ]
}

#######################################
### Tempo
#######################################

resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "lgtm-tempo"
  }
}

module "tempo_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.tempo
  service_account_name     = "tempo"
}

resource "helm_release" "tempo" {
  chart = "${path.module}/charts/tempo-distributed"

  name      = "tempo"
  namespace = kubernetes_namespace.tempo.metadata[0].name

  values = [
    templatefile("${path.module}/assets/tempo/values.yaml.tftpl", {
      tempo_service_account_name = module.tempo_service_account.kubernetes_service_account.metadata[0].name
    }),
  ]
}

#######################################
### Grafana
#######################################

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "lgtm-grafana"
  }
}

module "grafana_service_account" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gke-service-account/0.0.1.zip"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace.grafana
  service_account_name     = "grafana"
}

# roles required by GCP datasources
resource "google_project_iam_member" "grafana_gcp_datasources" {
  for_each = toset([
    "roles/cloudtrace.user",
    "roles/logging.viewAccessor",
    "roles/logging.viewer",
    "roles/monitoring.viewer",
  ])

  project = var.google_project.project_id
  role    = each.value
  member  = module.grafana_service_account.google_service_account.member
}

resource "helm_release" "grafana" {
  chart = "${path.module}/charts/grafana"

  name      = "grafana"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [
    templatefile("${path.module}/assets/grafana/values.yaml.tftpl", {
      grafana_service_account_name = module.grafana_service_account.kubernetes_service_account.metadata[0].name
      grafana_domain               = var.grafana_domain
    }),
    templatefile("${path.module}/assets/grafana/lgtm-datasources.yaml.tftpl", {
      loki_name       = helm_release.loki.name
      loki_namespace  = helm_release.loki.namespace
      mimir_name      = helm_release.mimir.name
      mimir_namespace = helm_release.mimir.namespace
      tempo_name      = helm_release.tempo.name
      tempo_namespace = helm_release.tempo.namespace
    }),
    templatefile("${path.module}/assets/grafana/gcp-datasources.yaml.tftpl", {
      project_id = var.google_project.project_id
    }),
  ]
}

#######################################
### OpenTelemetry Collector
#######################################

resource "kubernetes_namespace" "otelcol" {
  metadata {
    name = "lgtm-otelcol"
  }
}
