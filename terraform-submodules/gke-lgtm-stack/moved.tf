moved {
  from = google_storage_bucket_iam_member.loki
  to   = google_storage_bucket_iam_member.loki_service_account
}

moved {
  from = google_storage_bucket_iam_member.mimir
  to   = google_storage_bucket_iam_member.mimir_service_account
}

moved {
  from = google_storage_bucket_iam_member.tempo
  to   = google_storage_bucket_iam_member.tempo_service_account
}
