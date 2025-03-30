variable "kubernetes_service" {
  type = object({
    metadata = list(object({
      name      = string
      namespace = string
    }))
  })
}

variable "domain" {
  type = string
}

variable "service_port" {
  type    = number
  default = 80
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/healthy"
}

variable "is_domain_root" {
  type    = bool
  default = false
}
