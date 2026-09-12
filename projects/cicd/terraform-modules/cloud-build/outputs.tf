output "cloud_build_gsa" {
  value = google_service_account.cloud_build.email
}
