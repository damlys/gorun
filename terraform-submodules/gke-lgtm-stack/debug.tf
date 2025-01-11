locals {
  grafana_desc = "cluster: gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}, namespace: ${kubernetes_namespace.grafana.metadata[0].name}"
  grafana_hash = substr(sha256(local.grafana_desc), 0, 5)

  loki_desc = "cluster: gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}, namespace: ${kubernetes_namespace.loki.metadata[0].name}"
  loki_hash = substr(sha256(local.loki_desc), 0, 5)

  mimir_desc = "cluster: gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}, namespace: ${kubernetes_namespace.mimir.metadata[0].name}"
  mimir_hash = substr(sha256(local.mimir_desc), 0, 5)

  tempo_desc = "cluster: gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}, namespace: ${kubernetes_namespace.tempo.metadata[0].name}"
  tempo_hash = substr(sha256(local.tempo_desc), 0, 5)

  otelcol_desc = "cluster: gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}, namespace: ${kubernetes_namespace.otelcol.metadata[0].name}"
  otelcol_hash = substr(sha256(local.otelcol_desc), 0, 5)
}

resource "local_file" "grafana" {
  filename = "${path.module}/debug.grafana-${local.grafana_hash}.yaml"
  content  = data.helm_template.grafana.manifest
}

resource "local_file" "loki" {
  filename = "${path.module}/debug.loki-${local.loki_hash}.yaml"
  content  = data.helm_template.loki.manifest
}

resource "local_file" "mimir" {
  filename = "${path.module}/debug.mimir-${local.mimir_hash}.yaml"
  content  = data.helm_template.mimir.manifest
}

resource "local_file" "tempo" {
  filename = "${path.module}/debug.tempo-${local.tempo_hash}.yaml"
  content  = data.helm_template.tempo.manifest
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
    name = "lgtm-otelcol-debug"
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
    namespace = "lgtm-otelcol"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "node-opentelemetry-collector"
    namespace = "lgtm-otelcol"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "prometheus-collector"
    namespace = "lgtm-otelcol"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "prometheus-targetallocator"
    namespace = "lgtm-otelcol"
  }
}
