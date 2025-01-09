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

  loki_entrypoint  = "http://${data.helm_template.loki.name}-gateway.${data.helm_template.loki.namespace}.svc:80"
  mimir_entrypoint = "http://${data.helm_template.mimir.name}-nginx.${data.helm_template.mimir.namespace}.svc:80"
  tempo_entrypoint = "http://${data.helm_template.tempo.name}-query-frontend.${data.helm_template.tempo.namespace}.svc:3100"
}
