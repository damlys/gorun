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

variable "cluster_version" { # gcloud container get-server-config --project="gogcp-main-3" --region="europe-central2" --flatten="channels" --filter="channels.channel=STABLE" --format="value(channels.defaultVersion)"
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
    node_labels         = map(string)
    node_taints         = list(object({ key = string, value = string, effect = string }))
  }))
  default = {
    "main-pool-1" = {
      node_machine_type   = "n2d-standard-2"
      node_spot_instances = false
      node_min_instances  = 1
      node_max_instances  = 1
      node_labels         = {}
      node_taints         = []
    }
  }
}

variable "iam_cluster_viewers" {
  type    = set(string)
  default = []
}
