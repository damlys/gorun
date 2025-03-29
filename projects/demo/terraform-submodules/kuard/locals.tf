data "kubernetes_secret" "example" {
  metadata {
    name      = "example"
    namespace = "vault-kuard"
  }
}
