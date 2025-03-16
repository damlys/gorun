locals {
  gke_master_cidr = "10.0.0.0/28"
  gke_pod_cidr    = "10.1.0.0/20"
  gke_svc_cidr    = "10.2.0.0/20"
  vpc_subnet_cidr = "10.3.0.0/20"
  vpc_proxy_cidr  = "10.4.0.0/23"

  cluster       = "gke_${var.google_project.project_id}_${google_container_cluster.this.location}_${google_container_cluster.this.name}"
  velero_labels = { cluster = local.cluster, namespace = kubernetes_namespace.velero.metadata[0].name }
  velero_hash   = substr(sha256(yamlencode(local.velero_labels)), 0, 5)

  all_namespace_names = toset(concat(
    tolist(var.namespace_names),
    keys(var.iam_namespace_testers),
    keys(var.iam_namespace_developers),
  ))
  all_iam_namespace_members = toset(flatten(concat(
    values(var.iam_namespace_testers),
    values(var.iam_namespace_developers),
  )))
}

data "google_storage_project_service_account" "this" {
}
