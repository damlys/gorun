variable "google_project" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project"
  type = object({
    project_id = string
  })
}

variable "kubernetes_service_account" {
  description = "https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service_account"
  type = object({
    metadata = list(object({
      namespace = string
      name      = string

      uid = optional(string, "")
    }))
  })
}
