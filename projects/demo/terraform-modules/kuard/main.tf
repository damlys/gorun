module "vault" {
  source = "../../../core/terraform-submodules/k8s-vault" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-vault/0.5.100.zip"

  vault_name = "kuard"

  iam_readers = [
    "user:damlys.test@gmail.com",
  ]
  iam_writers = [
  ]
}

module "this" {
  source = "../../terraform-submodules/kuard" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/demo/kuard/0.5.100.zip"

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this

  platform_domain = "gogke-test-2.damlys.dev"
}
