resource "google_cloudbuild_trigger" "gomod_push_branch" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = data.github_repository.gomod.name
  description = "${local.cloud_build_connection_host}/${data.github_repository.gomod.full_name}"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.gomod.id
    push {
      branch = "^main$"
    }
  }
  included_files = ["**"]
  ignored_files  = ["**.md"]

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name       = local.devcontainer_image
      env        = [for k, v in local.cloud_build_envs : "${k}=${v}"]
      secret_env = [for k, _ in local.cloud_build_secret_envs : k]
      script = templatefile("${path.module}/assets/gomod.bash.tftpl", {
        git_host     = local.cloud_build_connection_host
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "push_branch"
      })
    }

    available_secrets {
      dynamic "secret_manager" {
        for_each = local.cloud_build_secret_envs
        content {
          env          = secret_manager.key
          version_name = "${google_secret_manager_secret.cloud_build_secret_envs[secret_manager.key].id}/versions/${secret_manager.value}"
        }
      }
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "gomod_pull_request" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = google_cloudbuild_trigger.gomod_push_branch.project
  location    = google_cloudbuild_trigger.gomod_push_branch.location
  name        = "${google_cloudbuild_trigger.gomod_push_branch.name}-pr"
  description = google_cloudbuild_trigger.gomod_push_branch.description
  disabled    = google_cloudbuild_trigger.gomod_push_branch.disabled

  repository_event_config {
    repository = google_cloudbuild_trigger.gomod_push_branch.repository_event_config[0].repository
    pull_request {
      branch = google_cloudbuild_trigger.gomod_push_branch.repository_event_config[0].push[0].branch
    }
  }
  included_files = google_cloudbuild_trigger.gomod_push_branch.included_files
  ignored_files  = google_cloudbuild_trigger.gomod_push_branch.ignored_files

  service_account = google_cloudbuild_trigger.gomod_push_branch.service_account
  build {
    step {
      name       = google_cloudbuild_trigger.gomod_push_branch.build[0].step[0].name
      env        = google_cloudbuild_trigger.gomod_push_branch.build[0].step[0].env
      secret_env = google_cloudbuild_trigger.gomod_push_branch.build[0].step[0].secret_env
      script = templatefile("${path.module}/assets/gomod.bash.tftpl", {
        git_host     = local.cloud_build_connection_host
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "pull_request"
      })
    }

    available_secrets {
      dynamic "secret_manager" {
        for_each = google_cloudbuild_trigger.gomod_push_branch.build[0].available_secrets[0].secret_manager
        content {
          env          = secret_manager.value.env
          version_name = secret_manager.value.version_name
        }
      }
    }

    options {
      logging = google_cloudbuild_trigger.gomod_push_branch.build[0].options[0].logging
    }
    logs_bucket = google_cloudbuild_trigger.gomod_push_branch.build[0].logs_bucket
  }
  include_build_logs = google_cloudbuild_trigger.gomod_push_branch.include_build_logs
}
