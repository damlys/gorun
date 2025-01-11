locals {
  common_config = yamldecode(templatefile("${path.module}/assets/config.yaml.tftpl", {
    loki_entrypoint  = var.loki_entrypoint
    mimir_entrypoint = var.mimir_entrypoint
    tempo_entrypoint = var.tempo_entrypoint
  }))
  cluster_config    = merge(local.common_config, yamldecode(file("${path.module}/assets/config.cluster.yaml")))
  node_config       = merge(local.common_config, yamldecode(file("${path.module}/assets/config.node.yaml")))
  prometheus_config = merge(local.common_config, yamldecode(file("${path.module}/assets/config.prometheus.yaml")))
  apps_config       = merge(local.common_config, yamldecode(file("${path.module}/assets/config.apps.yaml")))
}
