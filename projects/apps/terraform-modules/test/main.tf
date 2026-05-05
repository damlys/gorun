module "gomod_test_vault" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/core/k8s-vault/0.8.100.zip"
  source = "../../../core/terraform-submodules/k8s-vault"

  vault_name = "gomod-test-8"

  iam_readers = [
  ]
  iam_writers = [
    "serviceAccount:gha-damlys-gomod@gogcp-main-8.iam.gserviceaccount.com",
    "user:damlys.test@gmail.com",
  ]
}

module "gomod_test_workspace" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/core/k8s-workspace/0.8.100.zip"
  source = "../../../core/terraform-submodules/k8s-workspace"

  workspace_name = "gomod-test-8"

  iam_testers = [
  ]
  iam_developers = [
    "serviceAccount:gha-damlys-gomod@gogcp-main-8.iam.gserviceaccount.com",
    "user:damlys.test@gmail.com",
  ]
}

data "kubernetes_service" "goapp_test" {
  metadata {
    name      = "goapp-test-8"
    namespace = "gomod-test-8"
  }
}

module "goapp_test_gateway_http_route" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-8-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.8.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = data.kubernetes_service.goapp_test

  domain            = "goapp.gogke-test-8.damlys.dev"
  service_port      = 8080
  container_port    = 8080
  health_check_path = "/healthy"
}
