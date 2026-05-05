output "apm_server_endpoint" {
  value = "${data.kubernetes_service.apm_server.metadata[0].name}.${data.kubernetes_service.apm_server.metadata[0].namespace}.svc.cluster.local:8200"
}

output "apm_server_token" {
  value     = data.kubernetes_secret.apm_server_token.data["secret-token"]
  sensitive = true
}
