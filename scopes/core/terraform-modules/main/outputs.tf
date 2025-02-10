output "gcp_projects" {
  value = [
    module.main_project.google_project.project_id,
    module.test_project.google_project.project_id,
    module.prod_project.google_project.project_id,
  ]
}

output "terraform_state_buckets" {
  value = [
    module.terraform_state_bucket.google_storage_bucket.name,
  ]
}

output "docker_images_registries" {
  value = [
    module.public_docker_images_registry.ref,
    module.private_docker_images_registry.ref,
  ]
}

output "helm_charts_registries" {
  value = [
    module.public_helm_charts_registry.ref,
    module.private_helm_charts_registry.ref,
    module.external_helm_charts_registry.ref,
  ]
}

output "terraform_modules_registries" {
  value = [
    module.public_terraform_modules_registry.ref,
    module.private_terraform_modules_registry.ref,
  ]
}
