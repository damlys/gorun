provider "github" {
}

provider "google" {
  project = "gogcp-main-9"
}

data "google_project" "this" {
}
