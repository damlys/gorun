resource "kubernetes_namespace" "vault" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]
  for_each = local.all_vault_names

  metadata {
    name = "vault-${each.value}"
  }
}

resource "kubernetes_role_binding" "vault_viewers" {
  for_each = var.iam_vault_viewers

  metadata {
    namespace = kubernetes_namespace.vault[each.key].metadata[0].name
    name      = "custom:vault-viewers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vault_viewer.metadata[0].name
  }
  dynamic "subject" {
    for_each = each.value

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = kubernetes_namespace.gke_security_groups.metadata[0].name
    }
  }
}

resource "kubernetes_role_binding" "vault_editors" {
  for_each = var.iam_vault_editors

  metadata {
    namespace = kubernetes_namespace.vault[each.key].metadata[0].name
    name      = "custom:vault-editors"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vault_editor.metadata[0].name
  }
  dynamic "subject" {
    for_each = each.value

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = kubernetes_namespace.gke_security_groups.metadata[0].name
    }
  }
}

resource "kubernetes_manifest" "vault_velero_schedule_backup" {
  for_each = kubernetes_namespace.vault

  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "backup-${each.value.metadata[0].name}"
      namespace = helm_release.velero.namespace
    }
    spec = {
      schedule = "30 3 * * *" # UTC
      template = {
        ttl = "672h0m0s" # 28 days

        includedNamespaces = [each.value.metadata[0].name]
        includedResources  = ["configmaps", "secrets"]

        storageLocation = "default"
        snapshotVolumes = false
      }
    }
  }
}

resource "kubernetes_resource_quota" "vault_disable_pods_scheduling" {
  for_each = kubernetes_namespace.vault

  metadata {
    namespace = each.value.metadata[0].name
    name      = "disable-pods-scheduling"
  }
  spec {
    hard = {
      pods = 0
    }
  }
}
