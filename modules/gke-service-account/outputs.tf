output "gsa_id" {
  value = google_service_account.gsa.id
}

output "gsa_email" {
  value = google_service_account.gsa.email
}

output "ksa_name" {
  value = kubernetes_service_account.ksa.metadata[0].name
}
