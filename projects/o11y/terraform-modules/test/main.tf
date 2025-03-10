#######################################
### OpenTelemetry Operator
#######################################

resource "kubernetes_namespace" "opentelemetry_operator" {
  metadata {
    name = "opentelemetry-operator"
  }
}

resource "helm_release" "opentelemetry_operator" {
  repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/external-helm-charts/gorun"
  chart      = "opentelemetry-operator"
  version    = "0.82.0"

  name      = "opentelemetry-operator"
  namespace = kubernetes_namespace.opentelemetry_operator.metadata[0].name
  values    = [file("${path.module}/assets/opentelemetry_operator.yaml")]
}

# https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/k8sattributesprocessor/README.md#role-based-access-control
resource "kubernetes_cluster_role" "opentelemetry_collector" {
  metadata {
    name = "opentelemetry-collector"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
}

# https://github.com/open-telemetry/opentelemetry-operator/tree/main/cmd/otel-allocator#rbac
resource "kubernetes_cluster_role" "opentelemetry_targetallocator" {
  metadata {
    name = "opentelemetry-targetallocator"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "namespaces", "nodes", "nodes/metrics", "pods", "serviceaccounts", "services"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["servicemonitors", "podmonitors", "probes", "scrapeconfigs"]
    verbs      = ["*"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

#######################################
### OpenTelemetry & Grafana
#######################################

module "test_lgtm_stack" {
  source = "../../terraform-submodules/gke-lgtm-stack" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/o11y/gke-lgtm-stack/0.2.100.zip"

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this

  grafana_domain = "grafana.gogke-test-2.damlys.pl"
}

module "test_otel_collectors" {
  source = "../../terraform-submodules/k8s-otel-collectors" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/o11y/k8s-otel-collectors/0.2.100.zip"
  depends_on = [
    helm_release.opentelemetry_operator,
  ]

  loki_entrypoint  = module.test_lgtm_stack.loki_entrypoint
  mimir_entrypoint = module.test_lgtm_stack.mimir_entrypoint
  tempo_entrypoint = module.test_lgtm_stack.tempo_entrypoint
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
  repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/external-helm-charts/gorun"
  chart      = "base"
  version    = "1.25.0"

  name      = "istio-base"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  values    = [file("${path.module}/assets/istio_base.yaml")]
}

resource "helm_release" "istio_discovery" {
  depends_on = [
    helm_release.istio_base,
  ]

  repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/external-helm-charts/gorun"
  chart      = "istiod"
  version    = "1.25.0"

  name      = "istiod"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  values = [templatefile("${path.module}/assets/istio_discovery.yaml.tftpl", {
    opentelemetry_service = module.test_otel_collectors.otlp_grpc_host
    opentelemetry_port    = module.test_otel_collectors.otlp_grpc_port
  })]
}

resource "kubernetes_manifest" "istio_security_peer_authentication_default" {
  depends_on = [
    helm_release.istio_discovery,
  ]

  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = {
      mtls = {
        mode = "DISABLE" # mutual TLS is not needed as Istio is used only to collect tracking data
      }
    }
  }
}

resource "kubernetes_manifest" "istio_telemetry_default" {
  depends_on = [
    helm_release.istio_discovery,
  ]

  manifest = {
    apiVersion = "telemetry.istio.io/v1"
    kind       = "Telemetry" # https://istio.io/latest/docs/reference/config/telemetry/
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.istio_system.metadata[0].name
    }
    spec = {
      tracing = [{
        providers = [{
          name = "otel-tracing"
        }]
      }]
    }
  }
}
