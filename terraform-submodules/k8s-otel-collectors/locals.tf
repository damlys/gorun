locals {
  common_config = yamldecode(templatefile("${path.module}/assets/common_config.yaml.tftpl", {
    loki_entrypoint  = var.loki_entrypoint
    mimir_entrypoint = var.mimir_entrypoint
    tempo_entrypoint = var.tempo_entrypoint
  }))
  logs_config = merge(local.common_config, yamldecode(file("${path.module}/assets/logs_config.yaml")))
  prom_config = merge(local.common_config, yamldecode(file("${path.module}/assets/prom_config.yaml")))
  apps_config = merge(local.common_config, yamldecode(file("${path.module}/assets/apps_config.yaml")))
}
