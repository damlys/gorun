resource "google_storage_bucket" "this" {
  project  = var.google_project.project_id
  name     = "${var.google_project.project_id}-${var.bucket_name}"
  location = var.bucket_location

  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 100
    }
    action {
      type = "Delete"
    }
  }

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle {
    prevent_destroy = true
  }
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
