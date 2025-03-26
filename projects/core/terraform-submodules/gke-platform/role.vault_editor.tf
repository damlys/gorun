resource "kubernetes_cluster_role" "cluster_vault_editor" {
  metadata {
    name = "custom:vault-editor:cluster"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "namespace_vault_editor" {
  metadata {
    name = "custom:vault-editor:namespace"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
}
