#######################################
### Grafana
#######################################

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "lgtm-grafana"
  }

  timeouts {
    delete = "20m"
  }
}

module "grafana_service_account" {
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

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
  repository = "${path.module}/helm/charts"
  chart      = "postgresql"
  name       = "postgresql"
  namespace  = kubernetes_namespace.grafana.metadata[0].name

  values = [
    file("${path.module}/helm/values/postgresql.yaml"),
    templatefile("${path.module}/assets/grafana_postgresql/values.yaml.tftpl", {
    }),
  ]
}

resource "helm_release" "grafana" {
  repository = "${path.module}/helm/charts"
  chart      = "grafana"
  name       = "grafana"
  namespace  = kubernetes_namespace.grafana.metadata[0].name

  values = [
    file("${path.module}/helm/values/grafana.yaml"),
    templatefile("${path.module}/assets/grafana/values.yaml.tftpl", {
      grafana_service_account_name = module.grafana_service_account.kubernetes_service_account.metadata[0].name
      grafana_domain               = var.grafana_domain
      grafana_smtp_host            = nonsensitive(data.kubernetes_secret.smtp.data["host"])
      grafana_smtp_username        = nonsensitive(data.kubernetes_secret.smtp.data["username"])
      grafana_email                = var.grafana_email
      grafana_postgresql_host      = "${helm_release.grafana_postgresql.name}.${helm_release.grafana_postgresql.namespace}.svc.cluster.local"
      grafana_admin_email          = "damlys.test@gmail.com"
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

  set_sensitive {
    name  = "grafana\\.ini.smtp.password"
    type  = "string"
    value = data.kubernetes_secret.smtp.data["password"]
  }

  timeout = 300
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = helm_release.grafana.name
    namespace = helm_release.grafana.namespace
  }
}

module "grafana_gateway_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-route/0.2.100.zip"

  kubernetes_service = data.kubernetes_service.grafana

  domain            = var.grafana_domain
  service_port      = 80
  container_port    = 3000
  health_check_path = "/healthz"
}

module "grafana_availability_monitor" {
  source = "../gcp-availability-monitor" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/o11y/gcp-availability-monitor/0.2.100.zip"

  google_project = var.google_project

  request_host     = var.grafana_domain
  request_path     = "/healthz"
  response_content = "Ok"

  notification_emails = ["damlys.test@gmail.com"]
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
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

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
  repository = "${path.module}/helm/charts"
  chart      = "loki"
  name       = "loki"
  namespace  = kubernetes_namespace.loki.metadata[0].name

  values = [
    file("${path.module}/helm/values/loki.yaml"),
    templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
      loki_service_account_name = module.loki_service_account.kubernetes_service_account.metadata[0].name
      loki_bucket_name          = google_storage_bucket.loki.name
    }),
  ]

  timeout = 600
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
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

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
  repository = "${path.module}/helm/charts"
  chart      = "mimir-distributed"
  name       = "mimir"
  namespace  = kubernetes_namespace.mimir.metadata[0].name

  values = [
    file("${path.module}/helm/values/mimir-distributed.yaml"),
    templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
      mimir_service_account_name = module.mimir_service_account.kubernetes_service_account.metadata[0].name
      mimir_bucket_name          = google_storage_bucket.mimir.name
    }),
  ]

  timeout = 900
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
  source = "../../../core/terraform-submodules/gke-service-account" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-service-account/0.2.100.zip"

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
  repository = "${path.module}/helm/charts"
  chart      = "tempo-distributed"
  name       = "tempo"
  namespace  = kubernetes_namespace.tempo.metadata[0].name

  values = [
    file("${path.module}/helm/values/tempo-distributed.yaml"),
    templatefile("${path.module}/assets/tempo/values.yaml.tftpl", {
      tempo_service_account_name = module.tempo_service_account.kubernetes_service_account.metadata[0].name
      tempo_bucket_name          = google_storage_bucket.tempo.name
    }),
  ]

  timeout = 600
}
