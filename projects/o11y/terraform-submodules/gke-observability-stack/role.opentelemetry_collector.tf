# https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/k8sattributesprocessor#role-based-access-control
# https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8sclusterreceiver#rbac
resource "kubernetes_cluster_role" "opentelemetry_collector" {
  metadata {
    name = "opentelemetry-collector"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/status", "namespaces", "namespaces/status", "nodes", "nodes/spec", "nodes/stats", "nodes/proxy", "events", "resourcequotas", "services"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["events.k8s.io"]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps", "extensions"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["replicationcontrollers", "replicationcontrollers/status"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["autoscaling", "autoscaling.k8s.io"]
    resources  = ["horizontalpodautoscalers", "verticalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }
}
