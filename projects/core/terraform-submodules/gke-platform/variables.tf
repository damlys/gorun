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

variable "platform_dnssec_enabled" {
  type    = bool
  default = true
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

variable "kubectl_image_tag" { # https://hub.docker.com/r/bitnami/kubectl/tags
  type    = string
  default = null
}

variable "node_locations" {
  type    = set(string)
  default = ["europe-central2-a"]
}

variable "node_pools" {
  type = map(object({
    node_machine_type   = string
    node_spot_instances = bool
    node_min_instances  = number
    node_max_instances  = number
  }))
  default = {
    "main-pool-1" = {
      node_machine_type   = "n2d-standard-2"
      node_spot_instances = false
      node_min_instances  = 1
      node_max_instances  = 1
    }
  }
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

variable "vault_names" {
  type    = set(string)
  default = []
}

variable "iam_vault_viewers" {
  type    = map(set(string))
  default = {}
}
variable "iam_vault_editors" {
  type    = map(set(string))
  default = {}
}
