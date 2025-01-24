locals {
  common_config = yamldecode(templatefile("${path.module}/assets/common_config.yaml.tftpl", {
    loki_entrypoint  = var.loki_entrypoint
    mimir_entrypoint = var.mimir_entrypoint
    tempo_entrypoint = var.tempo_entrypoint
  }))
  file_config = merge(local.common_config, yamldecode(file("${path.module}/assets/file_config.yaml")))
  otlp_config = merge(local.common_config, yamldecode(file("${path.module}/assets/otlp_config.yaml")))
  prom_config = merge(local.common_config, yamldecode(file("${path.module}/assets/prom_config.yaml")))

  grpc_entrypoint = "http://${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector.${kubernetes_manifest.otlp_collector.manifest.metadata.namespace}.svc:4317"
  http_entrypoint = "http://${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector.${kubernetes_manifest.otlp_collector.manifest.metadata.namespace}.svc:4318"
}
