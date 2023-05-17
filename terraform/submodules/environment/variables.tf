variable "name" {
  type = string
}

variable "kuard_image_tag" {
  type = string
}

variable "kuard_config_envs" {
  type = map(string)
}

variable "kuard_secret_config_envs" {
  type      = map(string)
  sensitive = true
}
