resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name
  }
}

module "kuard" {
  source = "../kuard"

  namespace = kubernetes_namespace.this.metadata[0].name
  name      = "kuard"

  image_tag          = var.kuard_image_tag
  config_envs        = var.kuard_config_envs
  secret_config_envs = var.kuard_secret_config_envs
}
