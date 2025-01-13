#######################################
### logs
#######################################

resource "kubernetes_namespace" "logs_collector" {
  metadata {
    name = "otel-logs-collector"
  }
}

resource "kubernetes_manifest" "logs_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "logs"
      namespace = kubernetes_namespace.logs_collector.metadata[0].name
    }
    spec = {
      mode   = "daemonset"
      config = local.logs_config
      env    = local.common_envs

      volumes = [
        { name = "varlogpods", hostPath = { path = "/var/log/pods" } },
        { name = "varlibdockercontainers", hostPath = { path = "/var/lib/docker/containers" } },
      ]
      volumeMounts = [
        { name = "varlogpods", mountPath = "/var/log/pods", readOnly = true },
        { name = "varlibdockercontainers", mountPath = "/var/lib/docker/containers", readOnly = true },
      ]

      observability = { metrics = { enableMetrics = true } }
    }
  }
}

data "kubernetes_service_account" "logs_collector" {
  metadata {
    name      = "${kubernetes_manifest.logs_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.logs_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "logs_collector" {
  metadata {
    name = "${data.kubernetes_service_account.logs_collector.metadata[0].namespace}-${data.kubernetes_service_account.logs_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.logs_collector.metadata[0].name
    namespace = data.kubernetes_service_account.logs_collector.metadata[0].namespace
  }
}

#######################################
### prom
#######################################

resource "kubernetes_namespace" "prom_collector" {
  metadata {
    name = "otel-prom-collector"
  }
}

resource "kubernetes_service_account" "prom_targetallocator" {
  metadata {
    name      = "prom-targetallocator"
    namespace = kubernetes_namespace.prom_collector.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "prom_targetallocator" {
  metadata {
    name = "${kubernetes_service_account.prom_targetallocator.metadata[0].namespace}-${kubernetes_service_account.prom_targetallocator.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-targetallocator"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prom_targetallocator.metadata[0].name
    namespace = kubernetes_service_account.prom_targetallocator.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "prom_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "prom"
      namespace = kubernetes_namespace.prom_collector.metadata[0].name
    }
    spec = {
      mode   = "statefulset"
      config = local.prom_config
      env    = local.common_envs

      targetAllocator = {
        enabled        = true
        serviceAccount = kubernetes_service_account.prom_targetallocator.metadata[0].name
        prometheusCR = {
          enabled                = true
          podMonitorSelector     = {}
          serviceMonitorSelector = {}
          probeSelector          = {}
          scrapeConfigSelector   = {}
        }
      }

      observability = { metrics = { enableMetrics = true } }
    }
  }
}

data "kubernetes_service_account" "prom_collector" {
  metadata {
    name      = "${kubernetes_manifest.prom_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.prom_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "prom_collector" {
  metadata {
    name = "${data.kubernetes_service_account.prom_collector.metadata[0].namespace}-${data.kubernetes_service_account.prom_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.prom_collector.metadata[0].name
    namespace = data.kubernetes_service_account.prom_collector.metadata[0].namespace
  }
}

#######################################
### apps
#######################################

resource "kubernetes_namespace" "apps_collector" {
  metadata {
    name = "otel-apps-collector"
  }
}

resource "kubernetes_manifest" "apps_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "apps"
      namespace = kubernetes_namespace.apps_collector.metadata[0].name
    }
    spec = {
      mode   = "deployment"
      config = local.apps_config
      env    = local.common_envs

      observability = { metrics = { enableMetrics = true } }
    }
  }
}

data "kubernetes_service_account" "apps_collector" {
  metadata {
    name      = "${kubernetes_manifest.apps_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.apps_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "apps_collector" {
  metadata {
    name = "${data.kubernetes_service_account.apps_collector.metadata[0].namespace}-${data.kubernetes_service_account.apps_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.apps_collector.metadata[0].name
    namespace = data.kubernetes_service_account.apps_collector.metadata[0].namespace
  }
}
