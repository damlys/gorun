# TODO

resource "google_project_iam_member" "cluster_viewers" {
  for_each = local.all_cluster_iam_members

  project = var.google_project.project_id
  role    = "roles/container.clusterViewer"
  member  = each.value
}

resource "kubernetes_cluster_role_binding" "cluster_viewers" {
  metadata {
    name = "custom:cluster-viewers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_viewer.metadata[0].name
  }
  dynamic "subject" {
    for_each = local.all_cluster_iam_members

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = kubernetes_namespace.gke_security_groups.metadata[0].name
    }
  }
}
