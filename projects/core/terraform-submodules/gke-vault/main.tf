resource "kubernetes_namespace" "this" {
  metadata {
    name = "vault-${var.vault_name}"
  }
}

resource "kubernetes_resource_quota" "disable_pods_scheduling" {
  metadata {
    name      = "disable-pods-scheduling"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    hard = {
      pods = 0
    }
  }
}

resource "kubernetes_manifest" "velero_schedule" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "backup-${kubernetes_namespace.this.metadata[0].name}"
      namespace = "velero"
    }
    spec = {
      schedule = "30 3 * * *" # UTC
      template = {
        ttl = "672h0m0s" # 28 days

        includedNamespaces = [kubernetes_namespace.this.metadata[0].name]
        includedResources  = ["configmaps", "secrets"]

        storageLocation = "default"
        snapshotVolumes = false
      }
    }
  }
}

#######################################
### IAM
#######################################

resource "kubernetes_cluster_role_binding" "viewers" {
  count = length(var.iam_viewers) > 0 ? 1 : 0

  metadata {
    name = "custom:vault-viewers:${kubernetes_namespace.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:vault-viewer:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_viewers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_role_binding" "viewers" {
  count = length(var.iam_viewers) > 0 ? 1 : 0

  metadata {
    name      = "custom:vault-viewers"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:vault-viewer:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_viewers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_cluster_role_binding" "editors" {
  count = length(var.iam_editors) > 0 ? 1 : 0

  metadata {
    name = "custom:vault-editors:${kubernetes_namespace.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:vault-editor:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_editors

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_role_binding" "editors" {
  count = length(var.iam_editors) > 0 ? 1 : 0

  metadata {
    name      = "custom:vault-editors"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:vault-editor:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_editors

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}
