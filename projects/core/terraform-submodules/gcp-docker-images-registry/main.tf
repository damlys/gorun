resource "google_artifact_registry_repository" "this" {
  project       = var.google_project.project_id
  repository_id = var.registry_name
  location      = var.registry_location

  mode   = "STANDARD_REPOSITORY"
  format = "DOCKER"
  docker_config {
    immutable_tags = var.registry_immutability
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_artifact_registry_repository_iam_member" "readers" {
  project    = google_artifact_registry_repository.this.project
  repository = google_artifact_registry_repository.this.repository_id
  location   = google_artifact_registry_repository.this.location

  role     = "roles/artifactregistry.reader"
  for_each = var.iam_readers
  member   = each.key
}
resource "google_artifact_registry_repository_iam_member" "writers" {
  project    = google_artifact_registry_repository.this.project
  repository = google_artifact_registry_repository.this.repository_id
  location   = google_artifact_registry_repository.this.location

  role     = "roles/artifactregistry.writer"
  for_each = var.iam_writers
  member   = each.key
}
