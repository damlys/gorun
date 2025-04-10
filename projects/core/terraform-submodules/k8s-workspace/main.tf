resource "kubernetes_namespace" "this" {
  metadata {
    name = var.workspace_name
    labels = merge({
      "pod-security.kubernetes.io/enforce"         = "baseline"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "restricted"
      "pod-security.kubernetes.io/audit-version"   = "latest"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/warn-version"    = "latest"
    }, var.extra_namespace_labels)
    annotations = merge({
    }, var.extra_namespace_annotations)
  }

  lifecycle {
    prevent_destroy = true
  }

  timeouts {
    delete = "20m" # it takes about 10 minutes to delete a GKE gateway route (servicenetworkendpointgroups.networking.gke.io)
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
  count = length(var.iam_testers) > 0 ? 1 : 0

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
  count = length(var.iam_testers) > 0 ? 1 : 0

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
  count = length(var.iam_developers) > 0 ? 1 : 0

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
  count = length(var.iam_developers) > 0 ? 1 : 0

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
