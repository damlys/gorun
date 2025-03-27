resource "kubernetes_cluster_role" "cluster_vault_writer" {
  metadata {
    name = "custom:vault-writer:cluster"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "namespace_vault_writer" {
  metadata {
    name = "custom:vault-writer:namespace"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
}
