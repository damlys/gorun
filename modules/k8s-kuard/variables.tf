variable "name" {
  type    = string
  default = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "Value cannot be empty."
  }
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "service_account" {
  type    = string
  default = ""
  validation {
    condition     = length(var.service_account) > 0
    error_message = "Value cannot be empty."
  }
}

variable "host" {
  type    = string
  default = ""
  validation {
    condition     = length(var.host) > 0
    error_message = "Value cannot be empty."
  }
}

variable "path" {
  type    = string
  default = "/"
}
