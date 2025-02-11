variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "billing_account_id" {
  type    = string
  default = null
}

variable "services" {
  type = set(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",

    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",

    "certificatemanager.googleapis.com",
    "dns.googleapis.com",
    "networkservices.googleapis.com",

    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

variable "firebase_enabled" {
  type    = bool
  default = false
}

variable "iam_viewers" {
  type    = set(string)
  default = []
}
variable "iam_editors" {
  type    = set(string)
  default = []
}
variable "iam_owners" {
  type    = set(string)
  default = []
}
