variable "repository" {
  type    = string
  default = null
}

variable "chart" {
  type = string
}

variable "chart_version" { # the "version" attribute is reserved by Terraform and cannot be used here
  type    = string
  default = null
}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "values" {
  type = list(string)
}
