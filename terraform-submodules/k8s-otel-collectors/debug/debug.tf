resource "local_file" "debug_common_config" {
  filename = "${path.module}/debug/common_config.yaml"
  content  = yamlencode(local.common_config)
}

resource "local_file" "debug_logs_config" {
  filename = "${path.module}/debug/logs_config.yaml"
  content  = yamlencode(local.logs_config)
}

resource "local_file" "debug_prom_config" {
  filename = "${path.module}/debug/prom_config.yaml"
  content  = yamlencode(local.prom_config)
}

resource "local_file" "debug_apps_config" {
  filename = "${path.module}/debug/apps_config.yaml"
  content  = yamlencode(local.apps_config)
}
