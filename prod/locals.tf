locals {
  gcp_location = "EU"
  gcp_region   = "europe-central2"
  gcp_zones    = ["europe-central2-a"]

  gke_location = length(local.gcp_zones) == 1 ? local.gcp_zones[0] : local.gcp_region
}
