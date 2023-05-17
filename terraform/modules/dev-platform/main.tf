module "dev_platform" {
  source = "../../submodules/platform"

  google_client_config = data.google_client_config.oauth2
  google_project       = data.google_project.this

  name = "dev"

  gke_spot         = true
  gke_machine_type = "e2-standard-2"
}
