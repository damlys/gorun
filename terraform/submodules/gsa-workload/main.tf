resource "google_service_account" "this" {
  project    = var.google_project.project_id
  account_id = "k8s-${var.kubernetes_service_account.metadata[0].namespace}-${var.kubernetes_service_account.metadata[0].name}"
}

resource "kubernetes_annotations" "this" {
  count = local.ksa_exists ? 1 : 0

  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    namespace = var.kubernetes_service_account.metadata[0].namespace
    name      = var.kubernetes_service_account.metadata[0].name
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.this.email
  }
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.this.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.google_project.project_id}.svc.id.goog[${var.kubernetes_service_account.metadata[0].namespace}/${var.kubernetes_service_account.metadata[0].name}]"
}
