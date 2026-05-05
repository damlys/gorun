#######################################
### Vaults
#######################################

module "grafana_vault" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/core/k8s-vault/0.8.100.zip"
  source = "../../../core/terraform-submodules/k8s-vault"

  vault_name = "grafana"

  iam_readers = [
    "user:damlys.test@gmail.com",
  ]
  iam_writers = [
  ]
}

#######################################
### Observability stack
#######################################

module "test_o11y_stack" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/o11y/gke-observability-stack/0.8.100.zip"
  source = "../../terraform-submodules/gke-observability-stack"

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this

  grafana_domain = "grafana.gogke-test-8.damlys.dev"
  grafana_email  = "grafana@gogke-test-8.damlys.dev"

  blackbox_exporter_urls = [
    "https://grafana.gogke-test-8.damlys.dev/healthz",
    "https://stateful-kuard.gogke-test-8.damlys.dev/healthy",
    "https://stateless-kuard.gogke-test-8.damlys.dev/healthy",
  ]
}
