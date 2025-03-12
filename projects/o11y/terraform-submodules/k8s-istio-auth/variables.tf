variable "kubernetes_service" {
  type = object({
    metadata = list(object({
      name      = string
      namespace = string
    }))
    spec = list(object({
      selector = map(string)
    }))
  })
}
