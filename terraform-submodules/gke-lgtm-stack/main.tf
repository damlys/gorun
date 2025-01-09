resource "kubernetes_namespace" "otelcol" {
  metadata {
    name = "lgtm-otelcol"
  }
}

resource "helm_release" "otelcol_cluster" {
  chart     = data.helm_template.otelcol_cluster.chart
  name      = data.helm_template.otelcol_cluster.name
  namespace = data.helm_template.otelcol_cluster.namespace
  values    = data.helm_template.otelcol_cluster.values

  timeout = 300
}
data "helm_template" "otelcol_cluster" {
  chart = "${path.module}/charts/opentelemetry-collector"

  name      = "cluster"
  namespace = kubernetes_namespace.otelcol.metadata[0].name

  values = [
    templatefile("${path.module}/assets/otelcol_cluster/values.yaml.tftpl", {
      loki_entrypoint  = local.loki_entrypoint
      mimir_entrypoint = local.mimir_entrypoint
      tempo_entrypoint = local.tempo_entrypoint
    }),
  ]
}

resource "helm_release" "otelcol_node" {
  chart     = data.helm_template.otelcol_node.chart
  name      = data.helm_template.otelcol_node.name
  namespace = data.helm_template.otelcol_node.namespace
  values    = data.helm_template.otelcol_node.values

  timeout = 300
}
data "helm_template" "otelcol_node" {
  chart = "${path.module}/charts/opentelemetry-collector"

  name      = "node"
  namespace = kubernetes_namespace.otelcol.metadata[0].name

  values = [
    templatefile("${path.module}/assets/otelcol_node/values.yaml.tftpl", {
      loki_entrypoint  = local.loki_entrypoint
      mimir_entrypoint = local.mimir_entrypoint
      tempo_entrypoint = local.tempo_entrypoint
    }),
  ]
}
