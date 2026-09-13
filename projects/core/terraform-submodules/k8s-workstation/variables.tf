variable "workstation_name" {
  type = string
}

variable "workstation_domain" {
  type = string
}

variable "iam_owners" {
  type    = set(string)
  default = []
}
