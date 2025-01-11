locals {
  otelcol_desc = "namespace: ${kubernetes_namespace.otelcol.metadata[0].name}"
  otelcol_hash = substr(sha256(local.otelcol_desc), 0, 5)
}

resource "local_file" "otelcol_cluster" {
  filename = "${path.module}/debug.otelcol_cluster-${local.otelcol_hash}.yaml"
  content  = data.helm_template.otelcol_cluster.manifest
}

resource "local_file" "otelcol_node" {
  filename = "${path.module}/debug.otelcol_node-${local.otelcol_hash}.yaml"
  content  = data.helm_template.otelcol_node.manifest
}

resource "kubernetes_cluster_role_binding" "debug" {
  metadata {
    name = "${kubernetes_namespace.otelcol.metadata[0].name}-debug"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "cluster-opentelemetry-collector"
    namespace = kubernetes_namespace.otelcol.metadata[0].name
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "node-opentelemetry-collector"
    namespace = kubernetes_namespace.otelcol.metadata[0].name
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "prometheus-collector"
    namespace = kubernetes_namespace.otelcol.metadata[0].name
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "prometheus-targetallocator"
    namespace = kubernetes_namespace.otelcol.metadata[0].name
  }
}
