variable "vault_name" {
  type = string
}

variable "iam_viewers" {
  type    = set(string)
  default = []
}
variable "iam_editors" {
  type    = set(string)
  default = []
}
