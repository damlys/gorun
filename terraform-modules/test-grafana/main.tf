#######################################
### Web access
#######################################

data "google_compute_backend_service" "grafana" {
  project = data.google_project.this.project_id
  name    = "gkegw1-rxra-lgtm-grafana-grafana-80-3y1pnm1bpt5z"
}

resource "google_iap_web_backend_service_iam_member" "this" { # console.cloud.google.com/security/iap
  project             = data.google_project.this.project_id
  web_backend_service = data.google_compute_backend_service.grafana.name
  role                = "roles/iap.httpsResourceAccessor" # IAP-secured Web App User
  member              = each.value

  for_each = toset(concat(
    [data.google_service_account.grafana.member],
    [for v in local.user_accounts : "user:${v}"],
    [for v in local.service_accounts : "serviceAccount:${v}"],
  ))
}

#######################################
### CLI access
#######################################

data "google_service_account" "grafana" {
  project    = data.google_project.this.project_id
  account_id = "gke-grafana-9faa1"
}

resource "google_service_account_iam_member" "this" {
  service_account_id = data.google_service_account.grafana.name
  role               = "roles/iam.serviceAccountTokenCreator" # Service Account Token Creator
  member             = each.value

  for_each = toset(concat(
    [for v in local.user_accounts : "user:${v}"],
    [for v in local.service_accounts : "serviceAccount:${v}"],
  ))
}

#######################################
### Grafana provider
#######################################

# data "" "" { # console.cloud.google.com/auth/clients
#   x = "764086219165-hh5sjve1m8nmh7ge4lra8qfqi1387l4s.apps.googleusercontent.com"
# }

data "google_service_account_id_token" "grafana" {
  target_audience        = "764086219165-hh5sjve1m8nmh7ge4lra8qfqi1387l4s.apps.googleusercontent.com"
  target_service_account = data.google_service_account.grafana.email
  include_email          = true
}

provider "grafana" {
  url  = "https://grafana.gogke-test-7.damlys.pl"
  auth = "anonymous"

  http_headers = {
    "Authorization" = "Bearer ${data.google_service_account_id_token.grafana.id_token}"
  }
}

#######################################
### Grafana access
#######################################

resource "grafana_user" "this" {
  email    = each.value
  login    = each.value
  password = "Secret123"
  is_admin = true

  for_each = toset(concat(
    [for v in local.user_accounts : "accounts.google.com:${v}"],
    [for v in local.service_accounts : "accounts.google.com:${v}"],
  ))
}

#######################################
### Grafana resources
#######################################

resource "grafana_folder" "test_folder" {
  title = "Terraform Test Folder"
}
