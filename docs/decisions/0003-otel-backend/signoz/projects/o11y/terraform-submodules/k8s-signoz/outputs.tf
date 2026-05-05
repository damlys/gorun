output "signoz_endpoint" {
  value = "${data.kubernetes_service.signoz.metadata[0].name}-otel-collector.${data.kubernetes_service.signoz.metadata[0].namespace}.svc.cluster.local:4317"
}
