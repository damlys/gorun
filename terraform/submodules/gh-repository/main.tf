data "github_repository" "this" {
  full_name = "${var.owner}/${var.name}"
}

module "gsa" {
  source = "../gsa-workflow"

  google_iam_workload_identity_pool = var.google_iam_workload_identity_pool
  github_repository                 = data.github_repository.this
}

resource "google_kms_crypto_key" "sops" {
  key_ring = var.google_kms_key_ring.id
  name     = "gh-${var.owner}-${var.name}"
  purpose  = "ENCRYPT_DECRYPT"
}
