output "http_server_host" {
  value = "${kubernetes_service.http_server.metadata[0].name}.${kubernetes_service.http_server.metadata[0].namespace}.svc.cluster.local"
}

output "http_server_port" {
  value = kubernetes_service.http_server.spec[0].port[0].port
}
