locals {
  workstation_image = "europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images/gorun/core/workstation:0.9.101"

  code_selector_labels = {
    "app.kubernetes.io/name"    = "code"
    "app.kubernetes.io/part-of" = "workstation"
  }
  code_metadata_labels = merge(local.code_selector_labels, {
  })

  dind_selector_labels = {
    "app.kubernetes.io/name"    = "dind"
    "app.kubernetes.io/part-of" = "workstation"
  }
  dind_metadata_labels = merge(local.dind_selector_labels, {
  })
  dind_host = "tcp://${kubernetes_service_v1.dind.metadata[0].name}:2375"
}
