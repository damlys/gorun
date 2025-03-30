variable "workspace_name" {
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

variable "iam_testers" {
  type    = set(string)
  default = []
}
variable "iam_developers" {
  type    = set(string)
  default = []
}
