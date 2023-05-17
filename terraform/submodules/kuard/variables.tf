variable "name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "image_repository" {
  type    = string
  default = "europe-central2-docker.pkg.dev/gorun-general-2/public-docker-images/gorun/kuard"
}

variable "image_tag" {
  type    = string
  default = "0.0.0"
}

variable "config_envs" {
  type    = map(string)
  default = {}
}

variable "secret_config_envs" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "config_files" {
  type    = map(string)
  default = {}
}

variable "secret_config_files" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "min_http_server_replicas" {
  type    = number
  default = 1
}

variable "max_http_server_replicas" {
  type    = number
  default = 1
}
