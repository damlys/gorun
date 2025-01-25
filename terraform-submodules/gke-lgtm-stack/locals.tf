locals {
  cluster = "gke_${var.google_project.project_id}_${var.google_container_cluster.location}_${var.google_container_cluster.name}"

  loki_labels  = { cluster = local.cluster, namespace = kubernetes_namespace.loki.metadata[0].name }
  mimir_labels = { cluster = local.cluster, namespace = kubernetes_namespace.mimir.metadata[0].name }
  tempo_labels = { cluster = local.cluster, namespace = kubernetes_namespace.tempo.metadata[0].name }

  loki_hash  = substr(sha256(yamlencode(local.loki_labels)), 0, 5)
  mimir_hash = substr(sha256(yamlencode(local.mimir_labels)), 0, 5)
  tempo_hash = substr(sha256(yamlencode(local.tempo_labels)), 0, 5)

  loki_entrypoint  = "http://${data.helm_template.loki.name}-gateway.${data.helm_template.loki.namespace}.svc.cluster.local:80"
  mimir_entrypoint = "http://${data.helm_template.mimir.name}-nginx.${data.helm_template.mimir.namespace}.svc.cluster.local:80"
  tempo_entrypoint = "http://${data.helm_template.tempo.name}-gateway.${data.helm_template.tempo.namespace}.svc.cluster.local:80"
}
