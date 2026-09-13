locals {
  code_selector_labels = {
    "app.kubernetes.io/instance" = "code"
  }
  code_metadata_labels = merge(local.code_selector_labels, {
  })

  devcontainer = "europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images/gorun/core/devcontainer:0.9.101"
}
