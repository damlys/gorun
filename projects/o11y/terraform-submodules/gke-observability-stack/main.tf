#######################################
### ClickHouse
#######################################

resource "kubernetes_namespace_v1" "clickhouse" {
  metadata {
    name = "o11y-clickhouse"
  }
}

resource "helm_release" "clickhouse" {
  # PROD -dependency_update
  dependency_update = true

  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/core"
  repository = "../../../core/helm-charts"
  chart      = "clickhouse"
  version    = "0.9.100"

  name      = "clickhouse"
  namespace = kubernetes_namespace_v1.clickhouse.metadata[0].name

  values = [templatefile("${path.module}/assets/clickhouse.yaml.tftpl", {
  })]

  lifecycle {
    prevent_destroy = true
  }
}

#######################################
### Grafana
#######################################

resource "kubernetes_namespace_v1" "grafana" {
  metadata {
    name = "o11y-grafana"
  }
}

resource "helm_release" "grafana_postgres" {
  # PROD -dependency_update
  dependency_update = true

  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/core"
  repository = "../../../core/helm-charts"
  chart      = "postgres"
  version    = "0.9.100"

  name      = "grafana-postgres"
  namespace = kubernetes_namespace_v1.grafana.metadata[0].name

  values = [templatefile("${path.module}/assets/grafana_postgres.yaml.tftpl", {
  })]

  lifecycle {
    prevent_destroy = true
  }
}

module "grafana_service_account" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gke-service-account/0.9.100.zip"
  source = "../../../core/terraform-submodules/gke-service-account"

  google_project           = var.google_project
  google_container_cluster = var.google_container_cluster
  kubernetes_namespace     = kubernetes_namespace_v1.grafana
  service_account_name     = "grafana"
}

# roles required by Google Cloud datasources
resource "google_project_iam_member" "grafana_googlecloud_datasources" {
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
  # PROD -dependency_update
  dependency_update = true

  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "grafana"
  version    = "0.9.100"

  name      = "grafana"
  namespace = kubernetes_namespace_v1.grafana.metadata[0].name

  values = [templatefile("${path.module}/assets/grafana.yaml.tftpl", {
    grafana_domain = var.grafana_domain
    grafana_email  = var.grafana_email

    google_project_id    = var.google_project.project_id
    service_account_name = module.grafana_service_account.kubernetes_service_account.metadata[0].name
    postgres_host        = local.postgres_host
    clickhouse_host      = local.clickhouse_host
    smtp_host            = nonsensitive(data.kubernetes_secret_v1.grafana_smtp.data["host"])
    smtp_user            = nonsensitive(data.kubernetes_secret_v1.grafana_smtp.data["user"])
  })]

  set_sensitive = [
    { name = "secretConfigEnvs.GF_SMTP_PASSWORD", value = data.kubernetes_secret_v1.grafana_smtp.data["password"] },
  ]
}

data "kubernetes_service_v1" "grafana" {
  metadata {
    name      = helm_release.grafana.name
    namespace = helm_release.grafana.namespace
  }
}

module "grafana_gateway_http_route" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = data.kubernetes_service_v1.grafana

  domain            = var.grafana_domain
  service_port      = 80
  container_port    = 3000
  health_check_path = "/healthz"
}

module "grafana_availability_monitor" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/o11y/gcp-availability-monitor/0.9.100.zip"
  source = "../gcp-availability-monitor"

  google_project = var.google_project

  request_host     = var.grafana_domain
  request_path     = "/healthz"
  response_content = "Ok"

  notification_emails = ["damlys.test@gmail.com"]
}

#######################################
### otlp collector
#######################################

resource "kubernetes_namespace_v1" "otlp_collector" {
  metadata {
    name = "o11y-otlp-collector"
  }
}

resource "helm_release" "otlp_collector" {
  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "otelcol"
  version    = "0.9.100"

  name      = "otlp"
  namespace = kubernetes_namespace_v1.otlp_collector.metadata[0].name

  values = [templatefile("${path.module}/assets/otlp_collector.yaml.tftpl", {
    clickhouse_endpoint = local.clickhouse_endpoint
  })]
}

#######################################
### file collector
#######################################

resource "kubernetes_namespace_v1" "file_collector" {
  metadata {
    name = "o11y-file-collector"
  }
}

resource "helm_release" "file_collector" {
  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "otelcol"
  version    = "0.9.100"

  name      = "file"
  namespace = kubernetes_namespace_v1.file_collector.metadata[0].name

  values = [templatefile("${path.module}/assets/file_collector.yaml.tftpl", {
    clickhouse_endpoint = local.clickhouse_endpoint
  })]
}

#######################################
### kube collector
#######################################

resource "kubernetes_namespace_v1" "kube_collector" {
  metadata {
    name = "o11y-kube-collector"
  }
}

resource "helm_release" "kube_collector" {
  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "otelcol"
  version    = "0.9.100"

  name      = "kube"
  namespace = kubernetes_namespace_v1.kube_collector.metadata[0].name

  values = [templatefile("${path.module}/assets/kube_collector.yaml.tftpl", {
    clickhouse_endpoint = local.clickhouse_endpoint
  })]
}

#######################################
### node collector
#######################################

resource "kubernetes_namespace_v1" "node_collector" {
  metadata {
    name = "o11y-node-collector"
  }
}

resource "helm_release" "node_collector" {
  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "otelcol"
  version    = "0.9.100"

  name      = "node"
  namespace = kubernetes_namespace_v1.node_collector.metadata[0].name

  values = [templatefile("${path.module}/assets/node_collector.yaml.tftpl", {
    clickhouse_endpoint = local.clickhouse_endpoint
  })]
}

#######################################
### prom collector
#######################################

resource "kubernetes_namespace_v1" "prom_collector" {
  metadata {
    name = "o11y-prom-collector"
  }
}

resource "helm_release" "prom_collector" {
  # PROD repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts/gorun/o11y"
  repository = "../../helm-charts"
  chart      = "otelcol"
  version    = "0.9.100"

  name      = "prom"
  namespace = kubernetes_namespace_v1.prom_collector.metadata[0].name

  values = [templatefile("${path.module}/assets/prom_collector.yaml.tftpl", {
    clickhouse_endpoint = local.clickhouse_endpoint
  })]
}

#######################################
### blackbox exporter
#######################################

resource "kubernetes_namespace_v1" "blackbox_exporter" {
  metadata {
    name = "o11y-blackbox-exporter"
  }
}

resource "helm_release" "blackbox_exporter" {
  repository = "${path.module}/helm/charts"
  chart      = "prometheus-blackbox-exporter"

  name      = "prometheus-blackbox-exporter"
  namespace = kubernetes_namespace_v1.blackbox_exporter.metadata[0].name

  values = [
    file("${path.module}/helm/values/prometheus-blackbox-exporter.yaml"),
    templatefile("${path.module}/assets/blackbox_exporter.yaml.tftpl", {
      urls = var.blackbox_exporter_urls
    }),
  ]
}
