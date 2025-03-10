variable "google_client_config" {
  description = "oauth2"
  type = object({
    access_token = string
  })
}

variable "google_project" {
  type = object({
    project_id = string
    number     = number
  })
}

variable "platform_name" {
  type = string
}

variable "platform_domain" {
  type = string
}

variable "platform_region" {
  type    = string
  default = "europe-central2"
}

variable "cluster_location" {
  type    = string
  default = "europe-central2-a"
}

variable "cluster_version" { # gcloud container get-server-config --project="gogcp-main-2" --region="europe-central2" --flatten="channels" --filter="channels.channel=STABLE" --format="value(channels.defaultVersion)"
  type    = string
  default = null
}

variable "node_locations" {
  type    = set(string)
  default = ["europe-central2-a"]
}

variable "node_machine_type" {
  type    = string
  default = "n2d-standard-2"
}

variable "node_spot_instances" {
  type    = bool
  default = false
}

variable "node_min_instances" {
  type    = number
  default = 1
}

variable "node_max_instances" {
  type    = number
  default = 1
}

variable "namespace_names" {
  type    = set(string)
  default = []
}

variable "iam_namespace_testers" {
  type    = map(set(string))
  default = {}
}
variable "iam_namespace_developers" {
  type    = map(set(string))
  default = {}
}
