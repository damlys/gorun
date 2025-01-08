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
  chart = "${path.module}/charts/postgresql"

  name      = "postgresql"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [file("${path.module}/assets/grafana_postgresql/values.yaml")]
}

resource "helm_release" "grafana" {
  chart = "${path.module}/charts/grafana"

  name      = "grafana"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [
    templatefile("${path.module}/assets/grafana/values.yaml.tftpl", {
      grafana_service_account_name = module.grafana_service_account.kubernetes_service_account.metadata[0].name
      grafana_domain               = var.grafana_domain

      grafana_postgresql_name      = helm_release.grafana_postgresql.name
      grafana_postgresql_namespace = helm_release.grafana_postgresql.namespace
    }),
    templatefile("${path.module}/assets/grafana/lgtm-datasources.yaml.tftpl", {
      loki_name      = helm_release.loki.name
      loki_namespace = helm_release.loki.namespace

      mimir_name      = helm_release.mimir.name
      mimir_namespace = helm_release.mimir.namespace

      tempo_name      = helm_release.tempo.name
      tempo_namespace = helm_release.tempo.namespace
    }),
    templatefile("${path.module}/assets/grafana/gcp-datasources.yaml.tftpl", {
      project_id = var.google_project.project_id
    }),
    file("${path.module}/assets/grafana/resources.yaml"),
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
          name = "${helm_release.grafana.name}-service"
          port = 3000
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
        name  = "${helm_release.grafana.name}-service"
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
