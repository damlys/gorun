#######################################
### cluster
#######################################

resource "kubernetes_namespace" "cluster_collector" {
  metadata {
    name = "otel-cluster-collector"
  }
}

# resource "kubernetes_manifest" "cluster" {
#   manifest = {
#     apiVersion = "opentelemetry.io/v1beta1"
#     kind       = "OpenTelemetryCollector"
#     metadata = {
#       name      = "cluster"
#       namespace = kubernetes_namespace.cluster_collector.metadata[0].name
#     }
#     spec = {
#       mode   = "statefulset"
#       config = local.cluster_config
#     }
#   }
# }

#######################################
### node
#######################################

resource "kubernetes_namespace" "node_collector" {
  metadata {
    name = "otel-node-collector"
  }
}

# resource "kubernetes_manifest" "node" {
#   manifest = {
#     apiVersion = "opentelemetry.io/v1beta1"
#     kind       = "OpenTelemetryCollector"
#     metadata = {
#       name      = "node"
#       namespace = kubernetes_namespace.node_collector.metadata[0].name
#     }
#     spec = {
#       mode   = "daemonset"
#       config = local.node_config
#     }
#   }
# }

#######################################
### prometheus
#######################################

resource "kubernetes_namespace" "prometheus_collector" {
  metadata {
    name = "otel-prometheus-collector"
  }
}

resource "kubernetes_service_account" "prometheus_targetallocator" {
  metadata {
    name      = "prometheus-targetallocator"
    namespace = kubernetes_namespace.prometheus_collector.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "prometheus_targetallocator" {
  metadata {
    name = "${kubernetes_service_account.prometheus_targetallocator.metadata[0].namespace}-${kubernetes_service_account.prometheus_targetallocator.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector-targetallocator"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus_targetallocator.metadata[0].name
    namespace = kubernetes_service_account.prometheus_targetallocator.metadata[0].namespace
  }
}

# resource "kubernetes_manifest" "prometheus" {
#   manifest = {
#     apiVersion = "opentelemetry.io/v1beta1"
#     kind       = "OpenTelemetryCollector"
#     metadata = {
#       name      = "prometheus"
#       namespace = kubernetes_namespace.prometheus_collector.metadata[0].name
#     }
#     spec = {
#       mode = "statefulset"
#       targetAllocator = {
#         enabled        = true
#         serviceAccount = kubernetes_service_account.prometheus_targetallocator.metadata[0].name
#         prometheusCR = {
#           enabled                = true
#           podMonitorSelector     = {}
#           serviceMonitorSelector = {}
#         }
#       }
#       config = local.prometheus_config
#     }
#   }
# }

#######################################
### apps
#######################################

resource "kubernetes_namespace" "apps_collector" {
  metadata {
    name = "otel-apps-collector"
  }
}

# resource "kubernetes_manifest" "apps" {
#   manifest = {
#     apiVersion = "opentelemetry.io/v1beta1"
#     kind       = "OpenTelemetryCollector"
#     metadata = {
#       name      = "apps"
#       namespace = kubernetes_namespace.apps_collector.metadata[0].name
#     }
#     spec = {
#       mode   = "deployment"
#       config = local.apps_config
#     }
#   }
# }
