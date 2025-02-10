resource "google_service_account" "this" {
  project     = var.google_project.project_id
  account_id  = "gke-${var.service_account_name}-${local.gsa_hash}"
  description = local.gsa_desc
}

resource "kubernetes_service_account" "this" {
  metadata {
    namespace = var.kubernetes_namespace.metadata[0].name
    name      = var.service_account_name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.this.email
    }
  }
}

resource "google_service_account_iam_member" "this" {
  service_account_id = google_service_account.this.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_service_account.this.project}.svc.id.goog[${kubernetes_service_account.this.metadata[0].namespace}/${kubernetes_service_account.this.metadata[0].name}]"
}
