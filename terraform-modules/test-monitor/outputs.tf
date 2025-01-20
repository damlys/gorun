output "grafana_username" {
  value = module.test_lgtm_stack.grafana_username
}

output "grafana_password" {
  value     = module.test_lgtm_stack.grafana_password
  sensitive = true
}

output "annotations" {
  value = module.test_otel_collectors.annotations
}
