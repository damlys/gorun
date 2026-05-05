output "clickstack_endpoint" {
  description = "OTLP/gRPC host and port"
  value       = "${helm_release.clickstack.metadata.name}-otel-collector.${helm_release.clickstack.metadata.namespace}.svc.cluster.local:4317"
}

output "clickstack_api_key" {
  description = "Ingestion API Key"
  value       = "68a993d7-e25d-4805-85ce-d6b1d3f23779" # TODO
  sensitive   = true
}
