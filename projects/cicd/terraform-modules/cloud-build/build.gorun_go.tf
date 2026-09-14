resource "google_cloudbuild_trigger" "gorun_go" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.gorun.name}-go"
  description = "${local.cloud_build_connection_host}/${data.github_repository.gorun.full_name}//scripts/test go"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.gorun.id
    pull_request {
      branch = "^main$"
    }
  }
  included_files = ["go/**/*.go"]
  ignored_files  = []

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name   = local.devcontainer_image
      script = file("${path.module}/assets/build.gorun_go.bash")
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}
