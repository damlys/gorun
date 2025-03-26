# TODO

resource "google_project_iam_member" "cluster_viewers" {
  for_each = local.all_cluster_iam_members

  project = var.google_project.project_id
  role    = "roles/container.clusterViewer"
  member  = each.value
}
