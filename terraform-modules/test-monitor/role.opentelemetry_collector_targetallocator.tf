# https://github.com/open-telemetry/opentelemetry-operator/tree/main/cmd/otel-allocator#rbac
resource "kubernetes_cluster_role" "opentelemetry_collector_targetallocator" {
  metadata {
    name = "opentelemetry-collector-targetallocator"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "namespaces", "nodes", "nodes/metrics", "pods", "serviceaccounts", "services"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["servicemonitors", "podmonitors", "probes", "scrapeconfigs"]
    verbs      = ["*"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}
