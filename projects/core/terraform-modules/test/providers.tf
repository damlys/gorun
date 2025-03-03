provider "google" {
  project = "gogke-test-0"
}

data "google_client_config" "oauth2" {
}

data "google_project" "this" {
}
