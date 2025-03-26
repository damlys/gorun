module "test_platform" {
  source = "../../terraform-submodules/gke-platform" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-platform/0.2.105.zip"

  google_client_config = data.google_client_config.oauth2
  google_project       = data.google_project.this

  platform_name   = "gogke-test-2"
  platform_domain = "gogke-test-2.damlys.dev"

  node_pools = {
    "spot-pool-1" = {
      node_machine_type   = "n2d-standard-2"
      node_spot_instances = true
      node_min_instances  = 1
      node_max_instances  = 1
    }
  }

  iam_cluster_viewers = [
    "user:damlys.test@gmail.com",
  ]
}

module "test_workspace" {
  source = "../../terraform-submodules/gke-workspace" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-workspace/0.2.100.zip"
  depends_on = [
    module.test_platform,
  ]

  workspace_name = "gomod-test-2"

  iam_testers = [
  ]
  iam_developers = [
    "user:damlys.test@gmail.com",
  ]
}

module "kuard_workspace" {
  source = "../../terraform-submodules/gke-workspace" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-workspace/0.2.100.zip"
  depends_on = [
    module.test_platform,
  ]

  workspace_name = "kuard"

  iam_testers = [
    "user:damlys.test@gmail.com",
  ]
  iam_developers = [
  ]
}

module "grafana_vault" {
  source = "../../terraform-submodules/gke-vault" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-vault/0.2.100.zip"
  depends_on = [
    module.test_platform,
  ]

  vault_name = "grafana"

  iam_readers = [
    "user:damlys.test@gmail.com",
  ]
  iam_writers = [
  ]
}
