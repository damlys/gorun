provider "google" {
  project = "gogcp-test-2"
}

data "google_client_config" "oauth2" {
}

data "google_project" "this" {
}
