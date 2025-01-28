terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "google" {
}

provider "http" {
}

locals {
  client_id       = "764086219165-odk048stmh8m26dvs581a969ko87c6gh.apps.googleusercontent.com"
  service_account = "iap-accessor@gogke-test-0.iam.gserviceaccount.com"
  request_url     = "https://kuard.gogke-test-7.damlys.pl/healthy"
}

data "google_service_account_id_token" "this" {
  target_audience        = local.client_id
  target_service_account = local.service_account
  include_email          = true
}

data "http" "request" {
  url = local.request_url

  request_headers = {
    "Authorization" = "Bearer ${data.google_service_account_id_token.this.id_token}"
  }
}

output "response" {
  value = data.http.request.response_body
}
