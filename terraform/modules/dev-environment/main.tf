data "sops_file" "kuard_secret_config_envs" {
  source_file = "${path.module}/assets/kuard.enc.env"
}

module "dev_environment" {
  source = "../../submodules/environment"

  name = "dev"

  kuard_image_tag = "0.0.1"
  kuard_config_envs = {
    CONFIG_A = "dev CONFIG_A"
    CONFIG_B = "dev CONFIG_B"
  }
  kuard_secret_config_envs = data.sops_file.kuard_secret_config_envs.data
}
