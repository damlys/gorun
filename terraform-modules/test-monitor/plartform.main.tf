#######################################
### cert-manager
#######################################

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  repository = null
  chart      = "../../third_party/helm/charts/cert-manager" # TODO
  version    = null

  name      = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name
  values    = [file("${path.module}/assets/cert_manager.yaml")]
}

#######################################
### Prometheus Operator (CRDs)
#######################################

resource "kubernetes_namespace" "prometheus_operator" {
  metadata {
    name = "prometheus-operator"
  }
}

resource "helm_release" "prometheus_operator_crds" {
  repository = null
  chart      = "../../third_party/helm/charts/prometheus-operator-crds" # TODO
  version    = null

  name      = "prometheus-operator-crds"
  namespace = kubernetes_namespace.prometheus_operator.metadata[0].name
}

#######################################
### OpenTelemetry Operator
#######################################

resource "kubernetes_namespace" "opentelemetry_operator" {
  metadata {
    name = "opentelemetry-operator"
  }
}

resource "helm_release" "opentelemetry_operator" {
  depends_on = [
    helm_release.cert_manager,
  ]

  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-operator" # TODO
  version    = null

  name      = "opentelemetry-operator"
  namespace = kubernetes_namespace.opentelemetry_operator.metadata[0].name
  values    = [file("${path.module}/assets/opentelemetry_operator.yaml")]
}

#######################################
### Istio
#######################################

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  repository = null
  chart      = "../../third_party/helm/charts/base" # TODO
  version    = null

  name      = "istio-base"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  values    = [file("${path.module}/assets/istio_base.yaml")]
}

resource "helm_release" "istiod" {
  repository = null
  chart      = "../../third_party/helm/charts/istiod" # TODO
  version    = null

  name      = "istiod"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  values = [templatefile("${path.module}/assets/istiod.yaml.tftpl", {
    otlp_grpc_host = module.test_otel_collectors.otlp_grpc_host
    otlp_grpc_port = module.test_otel_collectors.otlp_grpc_port
  })]
}

resource "kubernetes_manifest" "istio_telemetry_default" {
  manifest = {
    apiVersion = "telemetry.istio.io/v1" # https://istio.io/latest/docs/reference/config/telemetry/
    kind       = "Telemetry"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = yamldecode(file("${path.module}/assets/istio_telemetry_default.yaml"))
  }
}
