variable "workstation_name" {
  type = string
}

variable "workstation_domain" {
  type = string
}

variable "extra_namespace_labels" {
  type    = map(string)
  default = {}
}

variable "extra_namespace_annotations" {
  type    = map(string)
  default = {}
}

variable "iam_owners" {
  type    = set(string)
  default = []
}
