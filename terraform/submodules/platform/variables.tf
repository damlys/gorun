variable "google_client_config" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config"
  type = object({
    access_token = string
  })
}

variable "google_project" {
  description = "https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project"
  type = object({
    project_id = string
    number     = number
  })
}

variable "name" {
  type = string
}

variable "vpc_ip_cidr_range" {
  type    = string
  default = "10.40.0.0/16"
}

variable "gke_master_ipv4_cidr_block" {
  type    = string
  default = "10.200.100.0/28"
}

variable "gke_cluster_ipv4_cidr_block" {
  type    = string
  default = "10.201.0.0/16"
}

variable "gke_services_ipv4_cidr_block" {
  type    = string
  default = "10.202.0.0/16"
}

variable "gke_version" {
  type    = string
  default = null
}

variable "gke_spot" {
  type    = bool
  default = false
}

variable "gke_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "gke_disk_size_gb" {
  type    = number
  default = 100
}

variable "gke_min_node_count" {
  type    = number
  default = 1
}

variable "gke_max_node_count" {
  type    = number
  default = 1
}
