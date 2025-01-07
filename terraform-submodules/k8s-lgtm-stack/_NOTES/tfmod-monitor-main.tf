module "test_lgtm_stack" {
  source = "../../terraform-submodules/k8s-lgtm-stack"

  grafana_domain = "grafana.gogke-test-7.damlys.pl"
}

output "grafana_username" {
  value = module.test_lgtm_stack.grafana_username
}

output "grafana_password" {
  value     = module.test_lgtm_stack.grafana_password
  sensitive = true
}
