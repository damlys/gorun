module "test_lgtm_stack" {
  source = "../../terraform-submodules/gke-lgtm-stack" # TODO

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this

  grafana_domain = "grafana.gogke-test-7.damlys.pl"
}

module "test_otel_collectors" {
  source = "../../terraform-submodules/k8s-otel-collectors" # TODO

  loki_entrypoint  = module.test_lgtm_stack.loki_entrypoint
  mimir_entrypoint = module.test_lgtm_stack.mimir_entrypoint
  tempo_entrypoint = module.test_lgtm_stack.tempo_entrypoint
}
