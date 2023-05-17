#######################################
### Docker images registries
#######################################

resource "google_artifact_registry_repository" "private_docker_images" {
  repository_id = "private-docker-images"
  location      = local.gcp_region
  mode          = "STANDARD_REPOSITORY"

  format = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

resource "google_artifact_registry_repository" "public_docker_images" {
  repository_id = "public-docker-images"
  location      = local.gcp_region
  mode          = "STANDARD_REPOSITORY"

  format = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}
resource "google_artifact_registry_repository_iam_member" "public_docker_images" {
  project    = google_artifact_registry_repository.public_docker_images.project
  repository = google_artifact_registry_repository.public_docker_images.name
  location   = google_artifact_registry_repository.public_docker_images.location
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

#######################################
### Helm charts registries
#######################################

resource "google_artifact_registry_repository" "private_helm_charts" {
  repository_id = "private-helm-charts"
  location      = local.gcp_region
  mode          = "STANDARD_REPOSITORY"

  format = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

resource "google_artifact_registry_repository" "public_helm_charts" {
  repository_id = "public-helm-charts"
  location      = local.gcp_region
  mode          = "STANDARD_REPOSITORY"

  format = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}
resource "google_artifact_registry_repository_iam_member" "public_helm_charts" {
  project    = google_artifact_registry_repository.public_helm_charts.project
  repository = google_artifact_registry_repository.public_helm_charts.name
  location   = google_artifact_registry_repository.public_helm_charts.location
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

#######################################
### Terraform modules registries
#######################################

resource "google_storage_bucket" "private_terraform_modules_registry" {
  name          = "${data.google_project.this.project_id}-private-terraform-modules"
  location      = local.gcp_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # prevent modifications to make artifacts immutable
  retention_policy {
    retention_period = 60 * 60 * 24 * 365 * 10 # 10 years
  }
}

resource "google_storage_bucket" "public_terraform_modules_registry" {
  name          = "${data.google_project.this.project_id}-public-terraform-modules"
  location      = local.gcp_region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true

  # prevent modifications to make artifacts immutable
  retention_policy {
    retention_period = 60 * 60 * 24 * 365 * 10 # 10 years
  }
}
resource "google_storage_bucket_iam_member" "public_terraform_modules_registry" {
  bucket = google_storage_bucket.public_terraform_modules_registry.name
  role   = "roles/storage.legacyObjectReader"
  member = "allUsers"
}
