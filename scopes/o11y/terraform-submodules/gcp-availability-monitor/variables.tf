variable "google_project" {
  type = object({
    project_id = string
  })
}

variable "request_method" {
  type    = string
  default = "GET"
}

variable "request_host" {
  type = string
}

variable "request_path" {
  type    = string
  default = "/healthy"
}

variable "response_content" {
  type    = string
  default = "Healthy."
}

variable "notification_emails" {
  type    = set(string)
  default = []
}
