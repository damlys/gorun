#######################################
### cert-manager
#######################################

resource "helm_release" "cert_manager_issuers" {
  depends_on = [
    helm_release.cert_manager,
  ]

  # repository = "oci://europe-central2-docker.pkg.dev/gogke-main-0/private-helm-charts/gogke/core"
  chart = "../../helm-charts/cert-manager-issuers" # "cert-manager-issuers"
  # version = "0.2.0"

  name      = "cert-manager-issuers"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name
}

#######################################
### Istio
#######################################

resource "kubernetes_namespace" "istio_system" {
  depends_on = [
    google_container_cluster.this,
  ]

  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  repository = "oci://europe-central2-docker.pkg.dev/gogke-main-0/external-helm-charts/gogcp"
  chart      = "base"
  version    = "1.24.2"

  name      = "istio-base"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  values    = [file("${path.module}/assets/istio_base.yaml")]
}

resource "helm_release" "istiod" {
  repository = "oci://europe-central2-docker.pkg.dev/gogke-main-0/external-helm-charts/gogcp"
  chart      = "istiod"
  version    = "1.24.2"

  name      = "istiod"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  values = [templatefile("${path.module}/assets/istiod.yaml.tftpl", {
    opentelemetry_service = "otlp-collector.otel-otlp-collector.svc.cluster.local"
    opentelemetry_port    = 4317
  })]
}

resource "kubernetes_manifest" "istio_telemetry_mesh_default" {
  depends_on = [
    helm_release.istiod,
  ]

  manifest = {
    apiVersion = "telemetry.istio.io/v1"
    kind       = "Telemetry" # https://istio.io/latest/docs/reference/config/telemetry/
    metadata = {
      name      = "mesh-default"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = yamldecode(file("${path.module}/assets/istio_telemetry_mesh_default.yaml"))
  }
}
