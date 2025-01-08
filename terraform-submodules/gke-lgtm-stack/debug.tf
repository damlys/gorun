resource "local_file" "grafana" {
  filename = "${path.module}/debug.grafana.yaml"
  content  = data.helm_template.grafana.manifest
}

resource "local_file" "loki" {
  filename = "${path.module}/debug.loki.yaml"
  content  = data.helm_template.loki.manifest
}

resource "local_file" "mimir" {
  filename = "${path.module}/debug.mimir.yaml"
  content  = data.helm_template.mimir.manifest
}

resource "local_file" "tempo" {
  filename = "${path.module}/debug.tempo.yaml"
  content  = data.helm_template.tempo.manifest
}
