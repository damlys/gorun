resource "google_project" "this" {
  project_id = var.id
  name       = var.name

  lifecycle {
    ignore_changes = [
      billing_account,
      org_id,
      folder_id,
    ]
  }

  # do not create default resources
  auto_create_network = false
}

resource "google_project_service" "this" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  project = google_project.this.project_id
  service = each.key
}

resource "google_compute_project_default_network_tier" "this" {
  project      = google_project.this.project_id
  network_tier = "PREMIUM"
}
