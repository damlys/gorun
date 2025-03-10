locals {
  gcp_location = "EU"
  gcp_region   = "europe-central2"
  gcp_zones    = ["europe-central2-a", "europe-central2-b", "europe-central2-c"]
  gcp_zone     = local.gcp_zones[0]
}
