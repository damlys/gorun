variable "domain" {
  type = string
}

variable "iam_owners" {
  type    = set(string)
  default = []
}
