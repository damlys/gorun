output "private_docker_images_registry" {
  value = "${google_artifact_registry_repository.private_docker_images.location}-docker.pkg.dev/${google_artifact_registry_repository.private_docker_images.project}/${google_artifact_registry_repository.private_docker_images.repository_id}"
}

output "public_docker_images_registry" {
  value = "${google_artifact_registry_repository.public_docker_images.location}-docker.pkg.dev/${google_artifact_registry_repository.public_docker_images.project}/${google_artifact_registry_repository.public_docker_images.repository_id}"
}

output "private_helm_charts_registry" {
  value = "oci://${google_artifact_registry_repository.private_helm_charts.location}-docker.pkg.dev/${google_artifact_registry_repository.private_helm_charts.project}/${google_artifact_registry_repository.private_helm_charts.repository_id}"
}

output "public_helm_charts_registry" {
  value = "oci://${google_artifact_registry_repository.public_helm_charts.location}-docker.pkg.dev/${google_artifact_registry_repository.public_helm_charts.project}/${google_artifact_registry_repository.public_helm_charts.repository_id}"
}

output "private_terraform_modules_registry" {
  value = google_storage_bucket.private_terraform_modules_registry.name
}

output "public_terraform_modules_registry" {
  value = google_storage_bucket.public_terraform_modules_registry.name
}
