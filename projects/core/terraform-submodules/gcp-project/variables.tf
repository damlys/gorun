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
