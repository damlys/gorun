locals {
  image_name = "gcr.io/kuar-demo/kuard-amd64"
  image_tag  = "v0.9-green"

  min_replicas = 1
  max_replicas = 2

  selector_labels = {
    "app.kubernetes.io/instance" = var.name
    "app.kubernetes.io/name"     = trim(substr(replace(local.image_name, "/[\\W]/", "_"), 0, 63), "_")
  }
  metadata_labels = merge(local.selector_labels, {
    "app.kubernetes.io/version" = trim(substr(replace(local.image_tag, "/[\\W]/", "_"), 0, 63), "_")
  })

  tls_secret_name = "tls-${join("-", reverse(split(".", var.host)))}"
}
