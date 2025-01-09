resource "local_file" "grafana" {
  filename = "${path.module}/debug.grafana-${local.grafana_hash}.yaml"
  content  = data.helm_template.grafana.manifest
}

resource "local_file" "loki" {
  filename = "${path.module}/debug.loki-${local.loki_hash}.yaml"
  content  = data.helm_template.loki.manifest
}

resource "local_file" "mimir" {
  filename = "${path.module}/debug.mimir-${local.mimir_hash}.yaml"
  content  = data.helm_template.mimir.manifest
}

resource "local_file" "tempo" {
  filename = "${path.module}/debug.tempo-${local.tempo_hash}.yaml"
  content  = data.helm_template.tempo.manifest
}

resource "local_file" "otelcol_logs" {
  filename = "${path.module}/debug.otelcol_logs-${local.otelcol_hash}.yaml"
  content  = data.helm_template.otelcol_logs.manifest
}
