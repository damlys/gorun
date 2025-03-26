resource "kubernetes_namespace" "this" {
  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.this,
  ]
  for_each = local.all_namespace_names

  metadata {
    name = each.value
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_role_binding" "namespace_testers" {
  for_each = var.iam_namespace_testers

  metadata {
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
    name      = "custom:namespace-testers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.namespace_tester.metadata[0].name
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

resource "kubernetes_role_binding" "namespace_developers" {
  for_each = var.iam_namespace_developers

  metadata {
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
    name      = "custom:namespace-developers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.namespace_developer.metadata[0].name
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

resource "kubernetes_manifest" "velero_schedule_backup" { # console.cloud.google.com/compute/snapshots
  for_each = kubernetes_namespace.this

  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule" # https://velero.io/docs/main/api-types/schedule/
    metadata = {
      name      = "backup-${each.value.metadata[0].name}"
      namespace = helm_release.velero.namespace
    }
    spec = {
      schedule = "30 3 * * *" # UTC
      template = {
        ttl = "72h0m0s" # 3 days

        includedNamespaces = [each.value.metadata[0].name]
        includedResources  = ["configmaps", "secrets", "persistentvolumeclaims", "persistentvolumes"]

        storageLocation         = "default"
        snapshotVolumes         = true
        volumeSnapshotLocations = ["default"]
      }
    }
  }
}
