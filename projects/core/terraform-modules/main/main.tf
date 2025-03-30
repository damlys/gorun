#######################################
### GCP projects
#######################################

module "main_project" {
  source = "../../terraform-submodules/gcp-project" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-project/0.3.100.zip"

  project_id   = "gogcp-main-2"
  project_name = "gogcp-main-2"

  iam_owners = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

module "test_project" {
  source = "../../terraform-submodules/gcp-project" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-project/0.3.100.zip"

  project_id   = "gogcp-test-2"
  project_name = "gogcp-test-2"

  iam_owners = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

module "prod_project" {
  source = "../../terraform-submodules/gcp-project" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-project/0.3.100.zip"

  project_id   = "gogcp-prod-2"
  project_name = "gogcp-prod-2"

  iam_owners = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform state buckets
#######################################

module "terraform_state_bucket" {
  source = "../../terraform-submodules/gcp-terraform-state-bucket" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-terraform-state-bucket/0.3.100.zip"

  google_project = module.main_project.google_project
  bucket_name    = "terraform-state"

  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

#######################################
### Docker images registries
#######################################

module "public_docker_images_registry" {
  source = "../../terraform-submodules/gcp-docker-images-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-docker-images-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-docker-images"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

module "private_docker_images_registry" {
  source = "../../terraform-submodules/gcp-docker-images-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-docker-images-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-docker-images"

  iam_readers = [
    "serviceAccount:gogke-test-2-gke-node@gogcp-test-2.iam.gserviceaccount.com",
  ]
  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

#######################################
### Helm charts registries
#######################################

module "public_helm_charts_registry" {
  source = "../../terraform-submodules/gcp-helm-charts-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-helm-charts-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-helm-charts"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

module "private_helm_charts_registry" {
  source = "../../terraform-submodules/gcp-helm-charts-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-helm-charts-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-helm-charts"

  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform submodules registries
#######################################

module "public_terraform_modules_registry" {
  source = "../../terraform-submodules/gcp-terraform-modules-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-terraform-modules-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "public-terraform-modules"

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}

module "private_terraform_modules_registry" {
  source = "../../terraform-submodules/gcp-terraform-modules-registry" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gcp-terraform-modules-registry/0.3.100.zip"

  google_project = module.main_project.google_project
  registry_name  = "private-terraform-modules"

  iam_writers = [
    "serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com",
  ]
}
