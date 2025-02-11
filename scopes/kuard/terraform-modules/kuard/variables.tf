variable "gcp_location" {
  type    = string
  default = "EU"
}

variable "gcp_region" {
  type    = string
  default = "europe-central2"
}

variable "gcp_zones" {
  type    = set(string)
  default = ["europe-central2-a", "europe-central2-b", "europe-central2-c"]
}

variable "gcp_zone" {
  type    = string
  default = "europe-central2-a"
}
