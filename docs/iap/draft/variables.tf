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

variable "iap_enabled" {
  type    = bool
  default = false
}

variable "iap_members" {
  type    = set(string)
  default = []
}
