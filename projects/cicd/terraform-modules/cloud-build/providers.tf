provider "github" {
}

provider "google" {
  project = "gogcp-main-8"
}

data "google_project" "this" {
}
