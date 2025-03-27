variable "vault_name" {
  type = string
}

variable "iam_readers" {
  type    = set(string)
  default = []
}
variable "iam_writers" {
  type    = set(string)
  default = []
}
