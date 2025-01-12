resource "local_file" "debug" {
  for_each = {
    grafana = data.helm_template.grafana
    loki    = data.helm_template.loki
    mimir   = data.helm_template.mimir
    tempo   = data.helm_template.tempo
  }

  filename = "${path.module}/debug/${each.key}.yaml"
  content  = each.value.manifest
}
