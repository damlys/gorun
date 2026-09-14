locals {
  workstation_image = "europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images/gorun/core/workstation:0.9.100"

  code_selector_labels = {
    "app.kubernetes.io/name"    = "code"
    "app.kubernetes.io/part-of" = "workstation"
  }
  code_metadata_labels = merge(local.code_selector_labels, {
  })
}
