variable "google_iam_workload_identity_pool" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool"
  type = object({
    name    = string
    project = string
  })
}

variable "google_kms_key_ring" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring"
  type = object({
    id = string
  })
}

variable "owner" {
  type = string
}

variable "name" {
  type = string
}
