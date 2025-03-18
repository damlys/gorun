module "test_platform" {
  source = "../../terraform-submodules/gke-platform" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/gke-platform/0.2.100.zip"

  google_client_config = data.google_client_config.oauth2
  google_project       = data.google_project.this

  platform_name   = "gogke-test-2"
  platform_domain = "gogke-test-2.damlys.dev"

  node_spot_instances = true

  namespace_names = [
    "gomod-test-2",
    "kuard",
  ]
  iam_namespace_testers = {
    "gomod-test-2" = [
      "user:damlys.test@gmail.com",
    ],
  }
  iam_namespace_developers = {
    "kuard" = [
      "user:damlys.test@gmail.com",
    ]
  }
}
