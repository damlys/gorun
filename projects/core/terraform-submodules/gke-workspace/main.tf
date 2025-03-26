resource "kubernetes_namespace" "this" {
  metadata {
    name = var.workspace_name
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_manifest" "velero_schedule" { # console.cloud.google.com/compute/snapshots
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule" # https://velero.io/docs/main/api-types/schedule/
    metadata = {
      name      = "backup-${kubernetes_namespace.this.metadata[0].name}"
      namespace = "velero"
    }
    spec = {
      schedule = "30 3 * * *" # UTC
      template = {
        ttl = "72h0m0s" # 3 days

        includedNamespaces = [kubernetes_namespace.this.metadata[0].name]
        includedResources  = ["configmaps", "secrets", "persistentvolumeclaims", "persistentvolumes"]

        storageLocation         = "default"
        snapshotVolumes         = true
        volumeSnapshotLocations = ["default"]
      }
    }
  }
}

#######################################
### IAM
#######################################

resource "kubernetes_cluster_role_binding" "testers" {
  metadata {
    name = "custom:workspace-testers:${kubernetes_namespace.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workspace-tester:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_testers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}
resource "kubernetes_role_binding" "testers" {
  metadata {
    name      = "custom:workspace-testers"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workspace-tester:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_testers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_cluster_role_binding" "developers" {
  metadata {
    name = "custom:workspace-developers:${kubernetes_namespace.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workspace-developer:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_developers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_role_binding" "developers" {
  metadata {
    name      = "custom:workspace-developers"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workspace-developer:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_developers

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}
