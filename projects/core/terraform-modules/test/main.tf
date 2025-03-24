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
      node_max_instances  = 2
    }
  }

  namespace_names = [
    "gomod-test-2",
    "kuard",
  ]
  iam_namespace_testers = {
    "gomod-test-2" = [
      "user:damlys.test@gmail.com",
    ]
  }
  iam_namespace_developers = {
    "kuard" = [
      "user:damlys.test@gmail.com",
    ]
  }

  vault_names = [
    "grafana",
  ]
  iam_vault_viewers = {
    "grafana" = [
      "user:damlys.test@gmail.com",
    ]
  }
  iam_vault_editors = {
  }
}
