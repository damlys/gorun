locals {
  repository_owner = split("/", var.github_repository.full_name)[0]
  repository_name  = split("/", var.github_repository.full_name)[1]
}
