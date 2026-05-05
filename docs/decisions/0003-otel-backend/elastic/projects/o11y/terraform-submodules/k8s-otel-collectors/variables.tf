variable "elastic_apm_server_endpoint" {
  type = string
}

variable "elastic_apm_server_token" {
  type      = string
  sensitive = true
}
