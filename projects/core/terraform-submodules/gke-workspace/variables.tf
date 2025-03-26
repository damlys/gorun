variable "workspace_name" {
  type = string
}

variable "iam_testers" {
  type    = set(string)
  default = []
}
variable "iam_developers" {
  type    = set(string)
  default = []
}
