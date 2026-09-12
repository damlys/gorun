resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "workstation-${var.workstation_name}"
    labels = merge({
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "privileged"
      "pod-security.kubernetes.io/audit-version"   = "latest"
      "pod-security.kubernetes.io/warn"            = "privileged"
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

#######################################
### IAM
#######################################

resource "kubernetes_cluster_role_binding_v1" "owners" {
  count = length(var.iam_owners) > 0 ? 1 : 0

  metadata {
    name = "custom:workstation-owners:${kubernetes_namespace_v1.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workstation-owner:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_owners

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_role_binding_v1" "owners" {
  count = length(var.iam_owners) > 0 ? 1 : 0

  metadata {
    name      = "custom:workstation-owners"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workstation-owner:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_owners

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}
