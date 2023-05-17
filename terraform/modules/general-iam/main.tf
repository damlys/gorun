#######################################
### Google project: gorun-general
#######################################

resource "google_project_iam_member" "general_owners" {
  project = "gorun-general-2"
  role    = "roles/owner"
  member  = each.key

  for_each = toset([
    "serviceAccount:gha-damlys-gomod@gorun-general-2.iam.gserviceaccount.com",
  ])
}

#######################################
### Google project: gorun-dev
#######################################

resource "google_project_iam_member" "dev_owners" {
  project = "gorun-dev-2"
  role    = "roles/owner"
  member  = each.key

  for_each = toset([
    "serviceAccount:gha-damlys-gomod@gorun-general-2.iam.gserviceaccount.com",
  ])
}

#######################################
### Google project: gorun-prod
#######################################

resource "google_project_iam_member" "prod_owners" {
  project = "gorun-prod-2"
  role    = "roles/owner"
  member  = each.key

  for_each = toset([
    "serviceAccount:gha-damlys-gomod@gorun-general-2.iam.gserviceaccount.com",
  ])
}

#######################################
### Registry: private-docker-images
#######################################

resource "google_artifact_registry_repository_iam_member" "private_docker_images_reader" {
  project    = "gorun-general-2"
  location   = "europe-central2"
  repository = "private-docker-images"
  role       = "roles/artifactregistry.reader"
  member     = each.key

  for_each = toset([
    "serviceAccount:gke-node-dev@gorun-dev-2.iam.gserviceaccount.com",
  ])
}
