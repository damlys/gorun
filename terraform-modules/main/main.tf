#######################################
### GCP projects
#######################################

module "main_project" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-project/0.0.2.zip"

  project_id   = "gogke-main-0"
  project_name = "gogke-main-0"

  iam_owners = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "test_project" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-project/0.0.2.zip"

  project_id   = "gogke-test-0"
  project_name = "gogke-test-0"

  iam_owners = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "prod_project" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-project/0.0.2.zip"

  project_id   = "gogke-prod-0"
  project_name = "gogke-prod-0"

  iam_owners = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform state buckets
#######################################

module "terraform_state_bucket" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-terraform-state-bucket/0.0.1.zip"

  google_project = module.main_project.google_project
  bucket_name    = "terraform-state"

  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

#######################################
### Docker images registries
#######################################

module "public_docker_images_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-docker-images-registry/0.0.2.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-docker-images"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "private_docker_images_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-docker-images-registry/0.0.2.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-docker-images"

  iam_readers = [
    "serviceAccount:gogke-test-7-gke-node@gogke-test-0.iam.gserviceaccount.com",
  ]
  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

#######################################
### Helm charts registries
#######################################

module "public_helm_charts_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-helm-charts-registry/0.0.2.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-helm-charts"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "private_helm_charts_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-helm-charts-registry/0.0.2.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-helm-charts"

  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "external_helm_charts_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-helm-charts-registry/0.0.2.zip"

  google_project = module.main_project.google_project
  registry_name  = "external-helm-charts"

  registry_immutability = false

  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform submodules registries
#######################################

module "public_terraform_modules_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-terraform-modules-registry/0.0.1.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-terraform-modules"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}

module "private_terraform_modules_registry" {
  source = "gcs::https://www.googleapis.com/storage/v1/gogke-main-0-private-terraform-modules/gogke/gcp-terraform-modules-registry/0.0.1.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-terraform-modules"

  iam_writers = [
    "serviceAccount:gha-damlys-gogcp@gogke-main-0.iam.gserviceaccount.com",
  ]
}
