output "gh_repositories" {
  value = [
    module.gorun_repository.full_name,
    module.gomod_repository.full_name,
  ]
}

output "gh_sops_keys" {
  value = [
    module.gorun_repository.sops_id,
    module.gomod_repository.sops_id,
  ]
}

output "gha_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}

output "gha_service_accounts" {
  value = [
    module.gorun_repository.gsa_email,
    module.gomod_repository.gsa_email,
  ]
}
