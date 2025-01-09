resource "kubernetes_namespace" "otelcol" {
  metadata {
    name = "lgtm-otelcol"
  }
}

resource "helm_release" "otelcol_logs" {
  chart     = data.helm_template.otelcol_logs.chart
  name      = data.helm_template.otelcol_logs.name
  namespace = data.helm_template.otelcol_logs.namespace
  values    = data.helm_template.otelcol_logs.values

  timeout = 300
}
data "helm_template" "otelcol_logs" {
  chart = "${path.module}/charts/opentelemetry-collector"

  name      = "logs"
  namespace = kubernetes_namespace.otelcol.metadata[0].name

  values = [
    templatefile("${path.module}/assets/otelcol_logs/values.yaml.tftpl", {
      loki_name      = data.helm_template.loki.name
      loki_namespace = data.helm_template.loki.namespace
    }),
  ]
}
