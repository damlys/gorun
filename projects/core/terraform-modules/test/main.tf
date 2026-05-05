module "test_platform" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/core/gke-platform/0.8.100.zip"
  source = "../../terraform-submodules/gke-platform"

  google_client_config = data.google_client_config.oauth2
  google_project       = data.google_project.this

  platform_name   = "gogke-test-8"
  platform_domain = "gogke-test-8.damlys.dev"

  node_pools = {
    "spot-pool-1" = {
      node_machine_type   = "e2-standard-2"
      node_spot_instances = true
      node_min_instances  = 1
      node_max_instances  = 1
      node_labels         = {}
      node_taints         = []
    }
  }

  iam_cluster_viewers = [
    "serviceAccount:gha-damlys-gomod@gogcp-main-8.iam.gserviceaccount.com",
    "user:damlys.test@gmail.com",
  ]
}
