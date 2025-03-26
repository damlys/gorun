# TODO delete this file

moved {
  from = module.test_platform.kubernetes_namespace.vault["grafana"]
  to   = module.grafana_vault.kubernetes_namespace.this
}
