#######################################
### otlp
#######################################

resource "kubernetes_namespace" "otlp_collector" {
  metadata {
    name = "otel-otlp-collector"
  }
}

resource "kubernetes_manifest" "otlp_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector" # https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/api/opentelemetrycollectors.md
    metadata = {
      name      = "otlp"
      namespace = kubernetes_namespace.otlp_collector.metadata[0].name
    }
    spec = {
      mode   = "deployment"
      config = local.otlp_config

      replicas = 1
      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability = { metrics = { enableMetrics = true } }
    }
  }
}

data "kubernetes_service_account" "otlp_collector" {
  metadata {
    name      = "${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.otlp_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "otlp_collector" {
  metadata {
    name = "${data.kubernetes_service_account.otlp_collector.metadata[0].namespace}-${data.kubernetes_service_account.otlp_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.otlp_collector.metadata[0].name
    namespace = data.kubernetes_service_account.otlp_collector.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "otlp_instrumentation" {
  manifest = {
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "Instrumentation" # https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/api/instrumentations.md
    metadata = {
      name      = "otlp-instrumentation"
      namespace = kubernetes_manifest.otlp_collector.manifest.metadata.namespace
    }
    spec = {
      exporter = {
        endpoint = local.otlp_grpc_entrypoint
      }
      dotnet = { env = [{ name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = local.otlp_grpc_entrypoint }] }
      go     = { env = [{ name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = local.otlp_grpc_entrypoint }] }
      java   = { env = [{ name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = local.otlp_grpc_entrypoint }] }
      nodejs = { env = [{ name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = local.otlp_grpc_entrypoint }] }
      python = { env = [{ name = "OTEL_EXPORTER_OTLP_ENDPOINT", value = local.otlp_http_entrypoint }] } # Python auto-instrumentation does not support gRPC protocol

      propagators = [
        "tracecontext",
        "baggage",
      ]
      sampler = {
        type = "always_on"
      }
    }
  }
}

#######################################
### file
#######################################

resource "kubernetes_namespace" "file_collector" {
  metadata {
    name = "otel-file-collector"
  }
}

resource "kubernetes_manifest" "file_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "file"
      namespace = kubernetes_namespace.file_collector.metadata[0].name
    }
    spec = {
      mode   = "daemonset"
      config = local.file_config

      volumes = [
        { name = "varlogpods", hostPath = { path = "/var/log/pods" } },
      ]
      volumeMounts = [
        { name = "varlogpods", mountPath = "/var/log/pods", readOnly = true },
      ]

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability = { metrics = { enableMetrics = true } }
    }
  }
}

data "kubernetes_service_account" "file_collector" {
  metadata {
    name      = "${kubernetes_manifest.file_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.file_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "file_collector" {
  metadata {
    name = "${data.kubernetes_service_account.file_collector.metadata[0].namespace}-${data.kubernetes_service_account.file_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.file_collector.metadata[0].name
    namespace = data.kubernetes_service_account.file_collector.metadata[0].namespace
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

      targetAllocator = { # https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/api/opentelemetrycollectors.md#opentelemetrycollectorspectargetallocator-1
        enabled        = true
        serviceAccount = kubernetes_service_account.prom_targetallocator.metadata[0].name
        prometheusCR = {
          enabled                = true
          podMonitorSelector     = {}
          serviceMonitorSelector = {}
          probeSelector          = {}
          scrapeConfigSelector   = {}
        }

        replicas = 1
        resources = {
          requests = { cpu = "1m", memory = "1Mi" }
          limits   = {}
        }
        observability = { metrics = { enableMetrics = true } }
      }

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
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
