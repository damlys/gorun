#######################################
### Cloud Build service account
#######################################

resource "google_service_account" "cloud_build" {
  project    = data.google_project.this.project_id
  account_id = "cloud-build"
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
  description = "${local.cloud_build_connection_domain}/${data.github_repository.monorepo.full_name}/${each.value.project_path}"
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
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "pull_request"
      })
    }

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
