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
