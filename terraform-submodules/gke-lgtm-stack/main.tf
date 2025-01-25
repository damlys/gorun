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

resource "helm_release" "grafana_postgresql" {
  repository = null
  chart      = "../../third_party/helm/charts/postgresql" # TODO
  version    = null

  name      = "postgresql"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [
    file("${path.module}/assets/grafana_postgresql/values.yaml"),
  ]
}

resource "helm_release" "grafana" {
  repository = data.helm_template.grafana.repository
  chart      = data.helm_template.grafana.chart
  version    = data.helm_template.grafana.version

  name      = data.helm_template.grafana.name
  namespace = data.helm_template.grafana.namespace
  values    = data.helm_template.grafana.values

  timeout = 300
}
data "helm_template" "grafana" {
  repository = null
  chart      = "../../third_party/helm/charts/grafana" # TODO
  version    = null

  name      = "grafana"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [
    file("${path.module}/assets/grafana/scale.yaml"),
    templatefile("${path.module}/assets/grafana/values.yaml.tftpl", {
      grafana_service_account_name = module.grafana_service_account.kubernetes_service_account.metadata[0].name
      grafana_domain               = var.grafana_domain

      grafana_postgresql_name      = helm_release.grafana_postgresql.name
      grafana_postgresql_namespace = helm_release.grafana_postgresql.namespace
    }),
    templatefile("${path.module}/assets/grafana/lgtm-datasources.yaml.tftpl", {
      loki_entrypoint  = local.loki_entrypoint
      mimir_entrypoint = local.mimir_entrypoint
      tempo_entrypoint = local.tempo_entrypoint
    }),
    templatefile("${path.module}/assets/grafana/gcp-datasources.yaml.tftpl", {
      project_id = var.google_project.project_id
    }),
  ]
}

resource "kubernetes_manifest" "grafana_httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = helm_release.grafana.name
      namespace = helm_release.grafana.namespace
    }
    spec = {
      parentRefs = [{
        kind        = "Gateway"
        namespace   = "gateway"
        name        = "gateway"
        sectionName = "https"
      }]
      hostnames = [var.grafana_domain]
      rules = [{
        backendRefs = [{
          name = helm_release.grafana.name
          port = 80
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "grafana_healthcheckpolicy" {
  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "HealthCheckPolicy"
    metadata = {
      name      = helm_release.grafana.name
      namespace = helm_release.grafana.namespace
    }
    spec = {
      targetRef = {
        group = ""
        kind  = "Service"
        name  = helm_release.grafana.name
      }
      default = {
        config = {
          type = "HTTP"
          httpHealthCheck = {
            port        = 3000
            requestPath = "/healthz"
          }
        }
      }
    }
  }
}

module "grafana_availability_monitor" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-availability-monitor/0.0.1.zip"

  google_project = var.google_project

  request_host     = var.grafana_domain
  request_path     = "/healthz"
  response_content = "Ok"

  notification_emails = ["damlys.test@gmail.com"] # TODO
}

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

resource "google_storage_bucket" "loki" {
  project       = var.google_project.project_id
  name          = "loki-${local.loki_hash}"
  labels        = local.loki_labels
  location      = var.platform_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "loki_service_account" {
  for_each = toset([
    "roles/storage.legacyBucketReader",
    "roles/storage.legacyObjectReader",
    "roles/storage.objectUser",
  ])

  bucket = google_storage_bucket.loki.name
  role   = each.value
  member = module.loki_service_account.google_service_account.member
}

resource "helm_release" "loki" {
  repository = data.helm_template.loki.repository
  chart      = data.helm_template.loki.chart
  version    = data.helm_template.loki.version

  name      = data.helm_template.loki.name
  namespace = data.helm_template.loki.namespace
  values    = data.helm_template.loki.values

  timeout = 600
}
data "helm_template" "loki" {
  repository = null
  chart      = "../../third_party/helm/charts/loki" # TODO
  version    = null

  name      = "loki"
  namespace = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/assets/loki/scale.yaml"),
    templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
      loki_service_account_name = module.loki_service_account.kubernetes_service_account.metadata[0].name
      loki_bucket_name          = google_storage_bucket.loki.name
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

resource "google_storage_bucket" "mimir" {
  project       = var.google_project.project_id
  name          = "mimir-${local.mimir_hash}"
  labels        = local.mimir_labels
  location      = var.platform_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "mimir_service_account" {
  for_each = toset([
    "roles/storage.legacyBucketReader",
    "roles/storage.legacyObjectReader",
    "roles/storage.objectUser",
  ])

  bucket = google_storage_bucket.mimir.name
  role   = each.value
  member = module.mimir_service_account.google_service_account.member
}

resource "helm_release" "mimir" {
  repository = data.helm_template.mimir.repository
  chart      = data.helm_template.mimir.chart
  version    = data.helm_template.mimir.version

  name      = data.helm_template.mimir.name
  namespace = data.helm_template.mimir.namespace
  values    = data.helm_template.mimir.values

  timeout = 900
}
data "helm_template" "mimir" {
  repository = null
  chart      = "../../third_party/helm/charts/mimir-distributed" # TODO
  version    = null

  name      = "mimir"
  namespace = kubernetes_namespace.mimir.metadata[0].name

  values = [
    file("${path.module}/assets/mimir/scale.yaml"),
    templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
      mimir_service_account_name = module.mimir_service_account.kubernetes_service_account.metadata[0].name
      mimir_bucket_name          = google_storage_bucket.mimir.name
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

resource "google_storage_bucket" "tempo" {
  project       = var.google_project.project_id
  name          = "tempo-${local.tempo_hash}"
  labels        = local.tempo_labels
  location      = var.platform_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "tempo_service_account" {
  for_each = toset([
    "roles/storage.legacyBucketReader",
    "roles/storage.legacyObjectReader",
    "roles/storage.objectUser",
  ])

  bucket = google_storage_bucket.tempo.name
  role   = each.value
  member = module.tempo_service_account.google_service_account.member
}

resource "helm_release" "tempo" {
  repository = data.helm_template.tempo.repository
  chart      = data.helm_template.tempo.chart
  version    = data.helm_template.tempo.version

  name      = data.helm_template.tempo.name
  namespace = data.helm_template.tempo.namespace
  values    = data.helm_template.tempo.values

  timeout = 600
}
data "helm_template" "tempo" {
  repository = null
  chart      = "../../third_party/helm/charts/tempo-distributed" # TODO
  version    = null

  name      = "tempo"
  namespace = kubernetes_namespace.tempo.metadata[0].name

  values = [
    file("${path.module}/assets/tempo/scale.yaml"),
    templatefile("${path.module}/assets/tempo/values.yaml.tftpl", {
      tempo_service_account_name = module.tempo_service_account.kubernetes_service_account.metadata[0].name
      tempo_bucket_name          = google_storage_bucket.tempo.name
    }),
  ]
}
