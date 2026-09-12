#######################################
### Cloud Build service accounts
#######################################

resource "google_service_account" "cloud_build_trigger_scheduler" {
  project    = data.google_project.this.project_id
  account_id = "cloud-build-trigger-scheduler"
}

resource "google_project_iam_member" "cloud_build_trigger_scheduler_builds_editor" {
  project = data.google_project.this.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.cloud_build_trigger_scheduler.email}"
}

resource "google_service_account" "cloud_build" {
  project    = data.google_project.this.project_id
  account_id = "cloud-build"
}

resource "google_service_account_iam_member" "cloud_build_service_account_user" {
  service_account_id = google_service_account.cloud_build.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloud_build_trigger_scheduler.email}"
}

#######################################
### Cloud Build logs bucket
#######################################

resource "google_storage_bucket" "cloud_build_logs" {
  project  = data.google_project.this.project_id
  location = local.gcp_region
  name     = "${data.google_project.this.project_id}-cloud-build-logs"

  storage_class = "STANDARD"

  lifecycle_rule {
    condition {
      matches_prefix = ["log-"]
      matches_suffix = [".txt"]
      age            = 21 # 3 weeks
    }
    action {
      type = "Delete"
    }
  }

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "cloud_build_logs_admin" {
  bucket = google_storage_bucket.cloud_build_logs.name
  role   = "roles/storage.admin"
  member = google_service_account.cloud_build.member
}

#######################################
### Cloud Build secrets
#######################################

resource "google_secret_manager_secret" "cloud_build_secret_envs" {
  for_each = local.cloud_build_secret_envs

  project   = data.google_project.this.project_id
  secret_id = "cloud-build-${each.key}"

  replication {
    user_managed {
      replicas {
        location = local.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_member" "cloud_build_secret_envs" {
  for_each = google_secret_manager_secret.cloud_build_secret_envs

  project   = data.google_project.this.project_id
  secret_id = each.value.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.gsa}"
}

#######################################
### GitHub repositories
#######################################

data "github_repository" "monorepo" {
  full_name = "damlys/gorun"
}

resource "google_cloudbuildv2_repository" "monorepo" {
  project           = data.google_project.this.project_id
  location          = local.gcp_region
  parent_connection = local.cloud_build_connection_name
  name              = data.github_repository.monorepo.full_name
  remote_uri        = data.github_repository.monorepo.http_clone_url
}

#######################################
### GitHub triggers
#######################################

resource "google_cloudbuild_trigger" "monorepo_push_branch" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]
  for_each = local.monorepo_projects

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.monorepo.name}-${each.value.project_slug}"
  description = "${local.cloud_build_connection_host}/${data.github_repository.monorepo.full_name}/${each.value.project_path}"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.monorepo.id
    push {
      branch = "^main$"
    }
  }
  included_files = ["${each.value.project_path}/**"]
  ignored_files  = ["${each.value.project_path}/README.md"]

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name       = local.devcontainer
      env        = [for k, v in local.cloud_build_envs : "${k}=${v}"]
      secret_env = [for k, _ in local.cloud_build_secret_envs : k]
      script = templatefile("${path.module}/assets/monorepo.bash.tftpl", {
        project_path = each.value.project_path
        project_type = each.value.project_type
        git_host     = local.cloud_build_connection_host
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "push_branch"
      })
    }
    timeout = "1200s" # 20 minutes

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

resource "google_cloudbuild_trigger" "monorepo_pull_request" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]
  for_each = local.monorepo_projects

  project     = google_cloudbuild_trigger.monorepo_push_branch[each.key].project
  location    = google_cloudbuild_trigger.monorepo_push_branch[each.key].location
  name        = "${google_cloudbuild_trigger.monorepo_push_branch[each.key].name}-pr"
  description = google_cloudbuild_trigger.monorepo_push_branch[each.key].description
  disabled    = google_cloudbuild_trigger.monorepo_push_branch[each.key].disabled

  repository_event_config {
    repository = google_cloudbuild_trigger.monorepo_push_branch[each.key].repository_event_config[0].repository
    pull_request {
      branch = google_cloudbuild_trigger.monorepo_push_branch[each.key].repository_event_config[0].push[0].branch
    }
  }
  included_files = google_cloudbuild_trigger.monorepo_push_branch[each.key].included_files
  ignored_files  = google_cloudbuild_trigger.monorepo_push_branch[each.key].ignored_files

  service_account = google_cloudbuild_trigger.monorepo_push_branch[each.key].service_account
  build {
    step {
      name       = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].step[0].name
      env        = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].step[0].env
      secret_env = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].step[0].secret_env
      script = templatefile("${path.module}/assets/monorepo.bash.tftpl", {
        project_path = each.value.project_path
        project_type = each.value.project_type
        git_host     = local.cloud_build_connection_host
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "pull_request"
      })
    }
    timeout = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].timeout

    available_secrets {
      dynamic "secret_manager" {
        for_each = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].available_secrets[0].secret_manager
        content {
          env          = secret_manager.value.env
          version_name = secret_manager.value.version_name
        }
      }
    }

    options {
      logging = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].options[0].logging
    }
    logs_bucket = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].logs_bucket
  }
  include_build_logs = google_cloudbuild_trigger.monorepo_push_branch[each.key].include_build_logs
}

resource "google_cloudbuild_trigger" "monorepo_test_bash" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.monorepo.name}-test-bash"
  description = "${local.cloud_build_connection_host}/${data.github_repository.monorepo.full_name} test bash"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.monorepo.id
    pull_request {
      branch = "^main$"
    }
  }
  included_files = ["scripts/**"]
  ignored_files  = []

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name   = local.devcontainer
      script = file("${path.module}/assets/monorepo_test_bash.bash")
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "monorepo_test_go" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.monorepo.name}-test-go"
  description = "${local.cloud_build_connection_host}/${data.github_repository.monorepo.full_name} test go"
  disabled    = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.monorepo.id
    pull_request {
      branch = "^main$"
    }
  }
  included_files = ["go/**/*.go"]
  ignored_files  = []

  service_account = google_service_account.cloud_build.id
  build {
    step {
      name   = local.devcontainer
      script = file("${path.module}/assets/monorepo_test_go.bash")
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "monorepo_dev_stop" {
  depends_on = [
    google_storage_bucket_iam_member.cloud_build_logs_admin,
  ]

  project     = data.google_project.this.project_id
  location    = local.gcp_region
  name        = "${data.github_repository.monorepo.name}-dev-stop"
  description = "${local.cloud_build_connection_host}/${data.github_repository.monorepo.full_name} dev stop"
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
      name   = local.devcontainer
      script = file("${path.module}/assets/monorepo_dev_stop.bash")
    }

    options {
      logging = "GCS_ONLY"
    }
    logs_bucket = google_storage_bucket.cloud_build_logs.url
  }
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloud_scheduler_job" "cloud_build_monorepo_dev_stop" {
  depends_on = [
    google_project_iam_member.cloud_build_trigger_scheduler_builds_editor,
    google_service_account_iam_member.cloud_build_service_account_user,
  ]

  project     = google_cloudbuild_trigger.monorepo_dev_stop.project
  region      = google_cloudbuild_trigger.monorepo_dev_stop.location
  name        = "cloud-build-${google_cloudbuild_trigger.monorepo_dev_stop.name}"
  description = "cloud build ${google_cloudbuild_trigger.monorepo_dev_stop.description}"
  schedule    = "0 12,20 * * *"
  time_zone   = "UTC"
  paused      = false

  http_target {
    http_method = "POST"
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${google_cloudbuild_trigger.monorepo_dev_stop.project}/locations/${google_cloudbuild_trigger.monorepo_dev_stop.location}/triggers/${google_cloudbuild_trigger.monorepo_dev_stop.trigger_id}:run"
    headers = {
      "Content-Type" = "application/json"
    }
    body = base64encode(jsonencode({
      projectId = google_cloudbuild_trigger.monorepo_dev_stop.project
      source = {
        branchName = "main"
      }
    }))
    oauth_token {
      service_account_email = google_service_account.cloud_build_trigger_scheduler.email
    }
  }
}
