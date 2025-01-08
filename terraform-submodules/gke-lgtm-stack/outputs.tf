output "grafana_username" {
  value = "admin"
}

output "grafana_password" {
  value     = "admin" # TODO
  sensitive = true
}
