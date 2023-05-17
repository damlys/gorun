resource "google_service_account" "this" {
  project    = var.google_iam_workload_identity_pool.project
  account_id = "gha-${local.repository_owner}-${local.repository_name}"
}

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.this.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.google_iam_workload_identity_pool.name}/attribute.repository/${local.repository_owner}/${local.repository_name}"
}
