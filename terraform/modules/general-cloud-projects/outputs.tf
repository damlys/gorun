output "gcp_projects" {
  value = [
    module.general_project.id,
    module.dev_project.id,
    module.prod_project.id,
  ]
}

output "tfstate_buckets" {
  value = [
    google_storage_bucket.general_tfstate.name,
  ]
}
