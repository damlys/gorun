resource "kubernetes_cluster_role" "cluster_vault_viewer" {
  metadata {
    name = "custom:vault-viewer:cluster"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "namespace_vault_viewer" {
  metadata {
    name = "custom:vault-viewer:namespace"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}
