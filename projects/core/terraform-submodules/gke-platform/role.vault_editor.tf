resource "kubernetes_cluster_role" "vault_editor" {
  metadata {
    name = "custom:vault-editor"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
}
