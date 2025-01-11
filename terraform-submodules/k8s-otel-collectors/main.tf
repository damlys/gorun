resource "kubernetes_namespace" "otelcol" {
  metadata {
    name = "otel-collectors"
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
  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-collector" # TODO
  version    = null

  name      = "cluster"
  namespace = kubernetes_namespace.otelcol.metadata[0].name

  values = [
    file("${path.module}/assets/otelcol/reset.yaml"),
    templatefile("${path.module}/assets/otelcol/values.yaml.tftpl", {
      loki_entrypoint  = var.loki_entrypoint
      mimir_entrypoint = var.mimir_entrypoint
      tempo_entrypoint = var.tempo_entrypoint
    }),
    file("${path.module}/assets/otelcol/cluster.yaml"),
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
  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-collector" # TODO
  version    = null

  name      = "node"
  namespace = kubernetes_namespace.otelcol.metadata[0].name

  values = [
    file("${path.module}/assets/otelcol/reset.yaml"),
    templatefile("${path.module}/assets/otelcol/values.yaml.tftpl", {
      loki_entrypoint  = var.loki_entrypoint
      mimir_entrypoint = var.mimir_entrypoint
      tempo_entrypoint = var.tempo_entrypoint
    }),
    file("${path.module}/assets/otelcol/node.yaml"),
  ]
}

resource "kubernetes_service_account" "otelcol_prometheus_targetallocator" {
  metadata {
    name      = "prometheus-targetallocator"
    namespace = kubernetes_namespace.otelcol.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "otelcol_prometheus_targetallocator" {
  metadata {
    name = "${kubernetes_service_account.otelcol_prometheus_targetallocator.metadata[0].namespace}-${kubernetes_service_account.otelcol_prometheus_targetallocator.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "opentelemetry-collector-targetallocator"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.otelcol_prometheus_targetallocator.metadata[0].name
    namespace = kubernetes_service_account.otelcol_prometheus_targetallocator.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "otelcol_prometheus" {
  manifest = {
    apiVersion = "opentelemetry.io/v1beta1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      name      = "prometheus"
      namespace = kubernetes_namespace.otelcol.metadata[0].name
    }
    spec = {
      mode = "statefulset"
      targetAllocator = {
        enabled        = true
        serviceAccount = kubernetes_service_account.otelcol_prometheus_targetallocator.metadata[0].name
        prometheusCR = {
          enabled                = true
          podMonitorSelector     = {}
          serviceMonitorSelector = {}
        }
      }
      config = yamldecode(templatefile("${path.module}/assets/otelcol/otelcol_prometheus_config.yaml.tftpl", {
        mimir_entrypoint = var.mimir_entrypoint
      }))
    }
  }
}
