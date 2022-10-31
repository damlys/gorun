output "internal_entrypoint" {
  value = "http://${kubernetes_service.http_server.metadata.0.name}"
}

output "external_entrypoint" {
  value = "https://${kubernetes_ingress_v1.http_server.spec.0.rule.0.host}"
}
