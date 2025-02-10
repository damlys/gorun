variable "google_project" {
  type = object({
    project_id = string
  })
}

variable "kubernetes_service" {
  type = object({
    metadata = list(object({
      name        = string
      namespace   = string
      labels      = map(string)
      annotations = map(string)
    }))
  })
}

variable "domain" {
  type = string
}

variable "service_port" {
  type    = number
  default = 80
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/healthy"
}

variable "iap_enabled" {
  type    = bool
  default = false
}

variable "iap_members" {
  type    = set(string)
  default = []
}
