#######################################
### GCP projects
#######################################

module "main_project" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-project/0.9.100.zip"
  source = "../../terraform-submodules/gcp-project"

  project_id   = "gogcp-main-9"
  project_name = "gogcp-main-9"

  billing_account_id = data.google_billing_account.this.id

  iam_owners = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

module "test_project" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-project/0.9.100.zip"
  source = "../../terraform-submodules/gcp-project"

  project_id   = "gogcp-test-9"
  project_name = "gogcp-test-9"

  billing_account_id = data.google_billing_account.this.id

  iam_owners = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

module "prod_project" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-project/0.9.100.zip"
  source = "../../terraform-submodules/gcp-project"

  project_id   = "gogcp-prod-9"
  project_name = "gogcp-prod-9"

  billing_account_id = data.google_billing_account.this.id

  iam_owners = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform state buckets
#######################################

module "terraform_state_bucket" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-terraform-state-bucket/0.9.100.zip"
  source = "../../terraform-submodules/gcp-terraform-state-bucket"

  google_project = module.main_project.google_project
  bucket_name    = "terraform-state"

  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

#######################################
### Docker images registries
#######################################

module "public_docker_images_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-docker-images-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-docker-images-registry"

  google_project = module.main_project.google_project
  registry_name  = "public-docker-images"

  registry_immutability = false

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

module "private_docker_images_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-docker-images-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-docker-images-registry"

  google_project = module.main_project.google_project
  registry_name  = "private-docker-images"

  registry_immutability = false

  iam_readers = [
    "serviceAccount:gogke-test-9-gke-node@gogcp-test-9.iam.gserviceaccount.com",
  ]
  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

#######################################
### Helm charts registries
#######################################

module "public_helm_charts_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-helm-charts-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-helm-charts-registry"

  google_project = module.main_project.google_project
  registry_name  = "public-helm-charts"

  registry_immutability = false

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

module "private_helm_charts_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-helm-charts-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-helm-charts-registry" #

  google_project = module.main_project.google_project
  registry_name  = "private-helm-charts"

  registry_immutability = false

  iam_readers = [
  ]
  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

#######################################
### Terraform submodules registries
#######################################

module "public_terraform_modules_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-terraform-modules-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-terraform-modules-registry"

  google_project = module.main_project.google_project
  registry_name  = "public-terraform-modules"

  registry_immutability = false

  iam_readers = ["allUsers"]
  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}

module "private_terraform_modules_registry" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/gcp-terraform-modules-registry/0.9.100.zip"
  source = "../../terraform-submodules/gcp-terraform-modules-registry"

  google_project = module.main_project.google_project
  registry_name  = "private-terraform-modules"

  registry_immutability = false

  iam_writers = [
    "serviceAccount:cloud-build@gogcp-main-9.iam.gserviceaccount.com",
  ]
}
