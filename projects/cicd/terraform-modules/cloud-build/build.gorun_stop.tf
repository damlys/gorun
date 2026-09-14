resource "google_cloudbuild_trigger" "gorun_stop" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.monorepo.name}-stop"
  description = "${local.cloud_build_connection_host}/${data.github_repository.monorepo.full_name}//scripts/dev stop"
  disabled    = true # git events are disabled, this trigger is only used by the Cloud Scheduler job

  repository_event_config {
    repository = google_cloudbuildv2_repository.monorepo.id
    push {
      branch = "^main$"
    }
  }

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name   = local.devcontainer_image
      script = file("${path.module}/assets/build.gorun_stop.bash")
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloud_scheduler_job" "cloud_build_gorun_stop" {
  depends_on = [
    google_project_iam_member.cloud_build_trigger_scheduler_builds_editor,
    google_service_account_iam_member.cloud_build_service_account_user,
  ]

  project     = google_cloudbuild_trigger.gorun_stop.project
  region      = google_cloudbuild_trigger.gorun_stop.location
  name        = "cloud-build-${google_cloudbuild_trigger.gorun_stop.name}"
  description = "cloud build ${google_cloudbuild_trigger.gorun_stop.description}"
  schedule    = "0 12,20 * * *"
  time_zone   = "UTC"
  paused      = false

  http_target {
    http_method = "POST"
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${google_cloudbuild_trigger.gorun_stop.project}/locations/${google_cloudbuild_trigger.gorun_stop.location}/triggers/${google_cloudbuild_trigger.gorun_stop.trigger_id}:run"
    headers = {
      "Content-Type" = "application/json"
    }
    body = base64encode(jsonencode({
      projectId = google_cloudbuild_trigger.gorun_stop.project
      source = {
        branchName = "main"
      }
    }))
    oauth_token {
      service_account_email = google_service_account.cloud_build_trigger_scheduler.email
    }
  }
}
