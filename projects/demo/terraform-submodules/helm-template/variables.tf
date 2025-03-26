variable "repository" {
  type    = string
  default = null
}

variable "chart" {
  type = string
}

variable "version_" { # the "version" attribute is reserved by Terraform and cannot be used here
  type    = string
  default = null
}

variable "namespace" {
  type = string
}

variable "name" {
  type = string
}

variable "values" {
  type = list(string)
}
