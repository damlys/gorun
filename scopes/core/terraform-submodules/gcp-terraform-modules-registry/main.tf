resource "google_storage_bucket" "this" {
  project  = var.google_project.project_id
  name     = "${var.google_project.project_id}-${var.registry_name}"
  location = var.registry_location

  storage_class = "STANDARD"

  # prevent modifications to make artifacts immutable
  retention_policy {
    retention_period = 60 * 60 * 24 * 365 * 10 # 10 years
  }

  uniform_bucket_level_access = true
  public_access_prevention    = contains(var.iam_readers, "allUsers") ? "inherited" : "enforced"
}

resource "google_storage_bucket_iam_member" "readers" {
  bucket = google_storage_bucket.this.name

  role     = "roles/storage.objectViewer"
  for_each = var.iam_readers
  member   = each.key
}
resource "google_storage_bucket_iam_member" "writers" {
  bucket = google_storage_bucket.this.name

  role     = "roles/storage.objectAdmin"
  for_each = var.iam_writers
  member   = each.key
}
