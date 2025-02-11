variable "google_project" {
  type = object({
    project_id = string
  })
}

variable "registry_name" {
  type = string
}

variable "registry_location" {
  type    = string
  default = "europe-central2"
}

variable "iam_readers" {
  type    = set(string)
  default = []
}
variable "iam_writers" {
  type    = set(string)
  default = []
}
