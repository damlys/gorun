resource "local_file" "debug_common_config" {
  filename = "${path.module}/debug/common_config.yaml"
  content  = yamlencode(local.common_config)
}

resource "local_file" "debug_file_config" {
  filename = "${path.module}/debug/file_config.yaml"
  content  = yamlencode(local.file_config)
}

resource "local_file" "debug_otlp_config" {
  filename = "${path.module}/debug/otlp_config.yaml"
  content  = yamlencode(local.otlp_config)
}

resource "local_file" "debug_prom_config" {
  filename = "${path.module}/debug/prom_config.yaml"
  content  = yamlencode(local.prom_config)
}
