#######################################
### otlp
#######################################

resource "kubernetes_namespace" "otlp_collector" {
  metadata {
    name = "o11y-otlp-collector"
  }
}

resource "kubernetes_secret" "otlp_collector_envs" {
  metadata {
    name      = "otlp-collector-envs"
    namespace = kubernetes_namespace.otlp_collector.metadata[0].name
  }
  data = {
    CLICKSTACK_API_KEY = var.clickstack_api_key
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
      mode     = "deployment"
      replicas = 1
      config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
        mode = "deployment"

        clickstack_endpoint = var.clickstack_endpoint

        logs_receivers    = ["otlp"]
        metrics_receivers = ["otlp"]
        traces_receivers  = ["otlp"]
      }))
      env     = [{ name = "K8S_NODE_NAME", valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } } }]
      envFrom = [{ secretRef = { name = kubernetes_secret.otlp_collector_envs.metadata[0].name } }]

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability  = { metrics = { enableMetrics = false } }
      podAnnotations = { "prometheus.io/scrape" = false }
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

#######################################
### file
#######################################

resource "kubernetes_namespace" "file_collector" {
  metadata {
    name = "o11y-file-collector"
  }
}

resource "kubernetes_secret" "file_collector_envs" {
  metadata {
    name      = "file-collector-envs"
    namespace = kubernetes_namespace.file_collector.metadata[0].name
  }
  data = {
    CLICKSTACK_API_KEY = var.clickstack_api_key
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
      mode = "daemonset"
      config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
        mode = "daemonset"

        clickstack_endpoint = var.clickstack_endpoint

        logs_receivers    = ["filelog"]
        metrics_receivers = []
        traces_receivers  = []
      }))
      env          = [{ name = "K8S_NODE_NAME", valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } } }]
      envFrom      = [{ secretRef = { name = kubernetes_secret.file_collector_envs.metadata[0].name } }]
      volumes      = [{ name = "varlogpods", hostPath = { path = "/var/log/pods" } }]
      volumeMounts = [{ name = "varlogpods", mountPath = "/var/log/pods", readOnly = true }]

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability  = { metrics = { enableMetrics = false } }
      podAnnotations = { "prometheus.io/scrape" = false }
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
### kube
#######################################

resource "kubernetes_namespace" "kube_collector" {
  metadata {
    name = "o11y-kube-collector"
  }
}

resource "kubernetes_secret" "kube_collector_envs" {
  metadata {
    name      = "kube-collector-envs"
    namespace = kubernetes_namespace.kube_collector.metadata[0].name
  }
  data = {
    CLICKSTACK_API_KEY = var.clickstack_api_key
  }
}

resource "kubernetes_manifest" "kube_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "kube"
      namespace = kubernetes_namespace.kube_collector.metadata[0].name
    }
    spec = {
      mode     = "deployment"
      replicas = 1 # do not scale up!
      config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
        mode = "deployment"

        clickstack_endpoint = var.clickstack_endpoint

        logs_receivers    = ["k8sobjects"]
        metrics_receivers = ["k8s_cluster"]
        traces_receivers  = []
      }))
      env     = [{ name = "K8S_NODE_NAME", valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } } }]
      envFrom = [{ secretRef = { name = kubernetes_secret.kube_collector_envs.metadata[0].name } }]

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability  = { metrics = { enableMetrics = false } }
      podAnnotations = { "prometheus.io/scrape" = false }
    }
  }
}

data "kubernetes_service_account" "kube_collector" {
  metadata {
    name      = "${kubernetes_manifest.kube_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.kube_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "kube_collector" {
  metadata {
    name = "${data.kubernetes_service_account.kube_collector.metadata[0].namespace}-${data.kubernetes_service_account.kube_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.kube_collector.metadata[0].name
    namespace = data.kubernetes_service_account.kube_collector.metadata[0].namespace
  }
}

#######################################
### node
#######################################

resource "kubernetes_namespace" "node_collector" {
  metadata {
    name = "o11y-node-collector"
  }
}

resource "kubernetes_secret" "node_collector_envs" {
  metadata {
    name      = "node-collector-envs"
    namespace = kubernetes_namespace.node_collector.metadata[0].name
  }
  data = {
    CLICKSTACK_API_KEY = var.clickstack_api_key
  }
}

resource "kubernetes_manifest" "node_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "node"
      namespace = kubernetes_namespace.node_collector.metadata[0].name
    }
    spec = {
      mode = "daemonset"
      config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
        mode = "daemonset"

        clickstack_endpoint = var.clickstack_endpoint

        logs_receivers    = []
        metrics_receivers = ["kubeletstats"]
        traces_receivers  = []
      }))
      env     = [{ name = "K8S_NODE_NAME", valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } } }]
      envFrom = [{ secretRef = { name = kubernetes_secret.node_collector_envs.metadata[0].name } }]

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability  = { metrics = { enableMetrics = false } }
      podAnnotations = { "prometheus.io/scrape" = false }
    }
  }
}

data "kubernetes_service_account" "node_collector" {
  metadata {
    name      = "${kubernetes_manifest.node_collector.manifest.metadata.name}-collector"
    namespace = kubernetes_manifest.node_collector.manifest.metadata.namespace
  }
}

resource "kubernetes_cluster_role_binding" "node_collector" {
  metadata {
    name = "${data.kubernetes_service_account.node_collector.metadata[0].namespace}-${data.kubernetes_service_account.node_collector.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = data.kubernetes_service_account.node_collector.metadata[0].name
    namespace = data.kubernetes_service_account.node_collector.metadata[0].namespace
  }
}

#######################################
### prom
#######################################

resource "kubernetes_namespace" "prom_collector" {
  metadata {
    name = "o11y-prom-collector"
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

resource "kubernetes_secret" "prom_collector_envs" {
  metadata {
    name      = "prom-collector-envs"
    namespace = kubernetes_namespace.prom_collector.metadata[0].name
  }
  data = {
    CLICKSTACK_API_KEY = var.clickstack_api_key
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
      mode     = "statefulset"
      replicas = 1
      config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
        mode = "statefulset"

        clickstack_endpoint = var.clickstack_endpoint

        logs_receivers    = []
        metrics_receivers = ["prometheus"]
        traces_receivers  = []
      }))
      env     = [{ name = "K8S_NODE_NAME", valueFrom = { fieldRef = { fieldPath = "spec.nodeName" } } }]
      envFrom = [{ secretRef = { name = kubernetes_secret.prom_collector_envs.metadata[0].name } }]

      targetAllocator = { # https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/api/opentelemetrycollectors.md#opentelemetrycollectorspectargetallocator-1
        enabled        = true
        replicas       = 1
        serviceAccount = kubernetes_service_account.prom_targetallocator.metadata[0].name
        prometheusCR = {
          enabled                = true
          podMonitorSelector     = {}
          serviceMonitorSelector = {}
          probeSelector          = {}
          scrapeConfigSelector   = {}
        }

        resources = {
          requests = { cpu = "1m", memory = "1Mi" }
          limits   = {}
        }
        observability = { metrics = { enableMetrics = false } }
      }

      resources = {
        requests = { cpu = "1m", memory = "1Mi" }
        limits   = {}
      }
      observability  = { metrics = { enableMetrics = false } }
      podAnnotations = { "prometheus.io/scrape" = false }
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

resource "kubernetes_manifest" "prom_pod_annotations" { # discovers metrics by pod annotations
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"
    metadata = {
      name      = "prom-pod-annotations"
      namespace = kubernetes_namespace.prom_collector.metadata[0].name
    }
    spec = {
      namespaceSelector = {
        any = true
      }
      selector = {
        matchLabels = {}
      }
      podMetricsEndpoints = [{
        relabelings = [ # https://github.com/prometheus-community/helm-charts/blob/2f1d889c6d5e7c3a73b61476b3efe7eed8385d35/charts/prometheus/values.yaml#L1109
          {
            sourceLabels = ["__meta_kubernetes_pod_annotation_prometheus_io_scrape"]
            action       = "keep"
            regex        = true
          },
          {
            sourceLabels = ["__meta_kubernetes_pod_annotation_prometheus_io_scheme"]
            action       = "replace"
            regex        = "(https?)"
            targetLabel  = "__scheme__"
          },
          {
            sourceLabels = ["__meta_kubernetes_pod_annotation_prometheus_io_path"]
            action       = "replace"
            regex        = "(.+)"
            targetLabel  = "__metrics_path__"
          },
          {
            sourceLabels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            action       = "replace"
            regex        = "(\\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})"
            replacement  = "[$2]:$1"
            targetLabel  = "__address__"
          },
          {
            sourceLabels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            action       = "replace"
            regex        = "(\\d+);((([0-9]+?)(\\.|$)){4})"
            replacement  = "$2:$1"
            targetLabel  = "__address__"
          },
        ]
      }]
    }
  }
}
