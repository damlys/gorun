resource "kubernetes_cluster_role" "cluster_vault_reader" {
  metadata {
    name = "custom:vault-reader:cluster"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role" "namespace_vault_reader" {
  metadata {
    name = "custom:vault-reader:namespace"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
}
