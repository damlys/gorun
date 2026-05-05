output "otlp_grpc_endpoint" {
  value = "${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector.${kubernetes_manifest.otlp_collector.manifest.metadata.namespace}.svc.cluster.local:4317"
}

output "otlp_http_endpoint" {
  value = "http://${kubernetes_manifest.otlp_collector.manifest.metadata.name}-collector.${kubernetes_manifest.otlp_collector.manifest.metadata.namespace}.svc.cluster.local:4318"
}
