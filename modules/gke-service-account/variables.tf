variable "name" {
  description = "Service account name."
  type        = string
  default     = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "Value cannot be empty."
  }
  validation {
    condition     = length(var.name) >= 6 && length(var.name) <= 30
    error_message = "Value must be between 6 and 30 characters."
  }
}

variable "project" {
  description = "Google project ID."
  type        = string
  default     = ""
  validation {
    condition     = length(var.project) > 0
    error_message = "Value cannot be empty."
  }
}

variable "namespace" {
  description = "Kubernetes namespace name."
  type        = string
  default     = ""
  validation {
    condition     = length(var.namespace) > 0
    error_message = "Value cannot be empty."
  }
}
