variable "google_project" {
  type = object({
    project_id = string
  })
}

variable "hyperdx_domain" {
  type = string
}
