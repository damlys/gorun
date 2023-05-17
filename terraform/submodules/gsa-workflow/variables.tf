variable "google_iam_workload_identity_pool" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool"
  type = object({
    name    = string
    project = string
  })
}

variable "github_repository" {
  description = "https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository"
  type = object({
    full_name = string
  })
}
