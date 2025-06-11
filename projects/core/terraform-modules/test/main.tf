#######################################
### Platforms
#######################################

module "test_platform" {
  source = "../../terraform-submodules/gke-platform" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-3-private-terraform-modules/gorun/core/gke-platform/0.5.100.zip"

  google_client_config = data.google_client_config.oauth2
  google_project       = data.google_project.this

  platform_name   = "gogke-test-3"
  platform_domain = "gogke-test-3.damlys.dev"

  node_pools = {
    "spot-pool-1" = {
      node_machine_type   = "n2d-standard-2"
      node_spot_instances = true
      node_min_instances  = 1
      node_max_instances  = 1
      node_labels         = {}
      node_taints         = []
    }
  }

  iam_cluster_viewers = [
    "user:damlys.test@gmail.com",
  ]
}

#######################################
### Vaults
#######################################

module "test_vault" {
  source = "../../terraform-submodules/k8s-vault" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-3-private-terraform-modules/gorun/core/k8s-vault/0.5.100.zip"
  depends_on = [
    module.test_platform,
  ]

  vault_name = "gomod-test-3"

  iam_readers = [
  ]
  iam_writers = [
    "user:damlys.test@gmail.com",
  ]
}

module "grafana_vault" {
  source = "../../terraform-submodules/k8s-vault" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-3-private-terraform-modules/gorun/core/k8s-vault/0.5.100.zip"
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

#######################################
### Workspaces
#######################################

module "test_workspace" {
  source = "../../terraform-submodules/k8s-workspace" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-3-private-terraform-modules/gorun/core/k8s-workspace/0.5.100.zip"
  depends_on = [
    module.test_platform,
  ]

  workspace_name = "gomod-test-3"

  iam_testers = [
  ]
  iam_developers = [
    "user:damlys.test@gmail.com",
  ]
}
