locals {
  ksa_exists = var.kubernetes_service_account.metadata[0].uid != ""
}
