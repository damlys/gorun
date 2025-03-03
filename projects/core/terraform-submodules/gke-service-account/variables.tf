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

variable "kubernetes_namespace" {
  type = object({
    metadata = list(object({
      name = string
    }))
  })
}

variable "service_account_name" {
  type = string
  validation { # min=6 and max=30 for google service account, but there is a "gke-" prefix and "-12345" suffix added
    condition     = length(var.service_account_name) <= 20
    error_message = "Value must be 20 characters or fewer."
  }
}
