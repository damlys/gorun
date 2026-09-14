module "damlys_workstation" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-workstation/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-workstation"

  workstation_name = "damlys"
  code_domain      = "damlys-code.gogke-test-9.damlys.pl"

  iam_owners = [
    "user:damlys.test@gmail.com",
  ]
}
