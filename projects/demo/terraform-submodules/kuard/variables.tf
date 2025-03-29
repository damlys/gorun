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

variable "platform_domain" {
  type = string
}
