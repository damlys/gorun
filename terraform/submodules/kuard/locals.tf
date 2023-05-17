locals {
  selector_labels = {
    "app.kubernetes.io/instance" = var.name
    "app.kubernetes.io/name"     = trim(substr(replace(var.image_repository, "/[\\W]/", "_"), 0, 63), "_")
  }
  metadata_labels = merge(local.selector_labels, {
    "app.kubernetes.io/version" = trim(substr(replace(var.image_tag, "/[\\W]/", "_"), 0, 63), "_")
  })

  configs_checksum = nonsensitive(sha256(jsonencode([
    var.config_envs,
    var.secret_config_envs,
    var.config_files,
    var.secret_config_files,
  ])))
}
