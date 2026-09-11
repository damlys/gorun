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

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

resource "google_storage_bucket_iam_member" "cloud_build_logs_admin" {
  bucket = google_storage_bucket.cloud_build_logs.name
  role   = "roles/storage.admin"
  member = google_service_account.cloud_build.member
}

#######################################
### GitHub access token
#######################################

resource "google_secret_manager_secret" "github_token" {
  project   = data.google_project.this.project_id
  secret_id = "github-token"

  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_iam_member" "github_token" {
  project   = data.google_project.this.project_id
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.gsa}"
}

# resource "google_secret_manager_secret_version" "github_token" {
#   secret      = google_secret_manager_secret.github_token.id
#   secret_data = var.github_token
# }

data "google_secret_manager_secret_version" "github_token" {
  secret = google_secret_manager_secret.github_token.id
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
      name = local.devcontainer
      script = templatefile("${path.module}/assets/monorepo.bash.tftpl", {
        project_path = each.value.project_path
        project_type = each.value.project_type
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "push_branch"
      })
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
      name = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].step[0].name
      script = templatefile("${path.module}/assets/monorepo.bash.tftpl", {
        project_path = each.value.project_path
        project_type = each.value.project_type
        git_name     = google_service_account.cloud_build.account_id
        git_email    = google_service_account.cloud_build.email
        github_event = "pull_request"
      })
    }

    options {
      logging = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].options[0].logging
    }
    logs_bucket = google_cloudbuild_trigger.monorepo_push_branch[each.key].build[0].logs_bucket
  }
  include_build_logs = google_cloudbuild_trigger.monorepo_push_branch[each.key].include_build_logs
}
