locals {
  common_config = yamldecode(templatefile("${path.module}/assets/common_config.yaml.tftpl", {
    loki_entrypoint  = var.loki_entrypoint
    mimir_entrypoint = var.mimir_entrypoint
    tempo_entrypoint = var.tempo_entrypoint
  }))
  file_config = merge(local.common_config, yamldecode(file("${path.module}/assets/file_config.yaml")))
  otlp_config = merge(local.common_config, yamldecode(file("${path.module}/assets/otlp_config.yaml")))
  prom_config = merge(local.common_config, yamldecode(file("${path.module}/assets/prom_config.yaml")))

  otlp_grpc_host = "${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector.${kubernetes_manifest.otlp_collector.manifest.metadata.namespace}.svc.cluster.local"
  otlp_http_host = local.otlp_grpc_host # they are the same

  otlp_grpc_port = 4317
  otlp_http_port = 4318

  otlp_grpc_entrypoint = "http://${local.otlp_grpc_host}:${local.otlp_grpc_port}"
  otlp_http_entrypoint = "http://${local.otlp_http_host}:${local.otlp_http_port}"
}
