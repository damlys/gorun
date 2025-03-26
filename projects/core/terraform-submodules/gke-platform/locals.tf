locals {
  gke_master_cidr = "10.0.0.0/28"
  gke_pod_cidr    = "10.1.0.0/20"
  gke_svc_cidr    = "10.2.0.0/20"
  vpc_subnet_cidr = "10.3.0.0/20"
  vpc_proxy_cidr  = "10.4.0.0/23"

  cluster       = "gke_${var.google_project.project_id}_${google_container_cluster.this.location}_${google_container_cluster.this.name}"
  velero_labels = { cluster = local.cluster, namespace = kubernetes_namespace.velero.metadata[0].name }
  velero_hash   = substr(sha256(yamlencode(local.velero_labels)), 0, 5)

  all_cluster_iam_members = toset(flatten(concat(
    values(var.iam_workspace_testers),
    values(var.iam_workspace_developers),
    values(var.iam_vault_viewers),
    values(var.iam_vault_editors),
  )))
  all_namespace_names = toset(concat(
    tolist(var.namespace_names),
    keys(var.iam_workspace_testers),
    keys(var.iam_workspace_developers),
  ))
  all_vault_names = toset(concat(
    tolist(var.vault_names),
    keys(var.iam_vault_viewers),
    keys(var.iam_vault_editors),
  ))
}

data "google_storage_project_service_account" "this" {
}
