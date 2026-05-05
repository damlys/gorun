variable "google_project" {
  type = object({
    project_id = string
  })
}

variable "google_container_cluster" {
  type = object({
    location = string
    name     = string
  })
}

variable "grafana_domain" {
  type = string
}

variable "grafana_email" {
  type = string
}

variable "blackbox_exporter_urls" {
  type    = set(string)
  default = []
}
