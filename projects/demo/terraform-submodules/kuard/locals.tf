data "kubernetes_secret_v1" "example" {
  metadata {
    name      = "example"
    namespace = "vault-kuard"
  }
}
