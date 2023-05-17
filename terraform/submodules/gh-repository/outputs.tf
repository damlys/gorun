output "full_name" {
  value = data.github_repository.this.full_name
}

output "github_repository" {
  value = data.github_repository.this
}

output "gsa_id" {
  value = module.gsa.id
}

output "gsa_email" {
  value = module.gsa.email
}

output "gsa_member" {
  value = module.gsa.member
}

output "gsa_google_service_account" {
  value = module.gsa.google_service_account
}

output "sops_id" {
  value = google_kms_crypto_key.sops.id
}

output "sops_google_kms_crypto_key" {
  value = google_kms_crypto_key.sops
}
