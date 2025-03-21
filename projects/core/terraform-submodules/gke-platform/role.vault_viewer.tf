resource "kubernetes_cluster_role" "vault_viewer" {
  metadata {
    name = "custom:vault-viewer"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}
