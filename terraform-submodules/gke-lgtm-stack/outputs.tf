output "grafana_username" {
  value = "admin"
}

output "grafana_password" {
  value     = "admin" # TODO
  sensitive = true
}

output "loki_entrypoint" {
  value = local.loki_entrypoint
}

output "mimir_entrypoint" {
  value = local.mimir_entrypoint
}

output "tempo_entrypoint" {
  value = local.tempo_entrypoint
}
