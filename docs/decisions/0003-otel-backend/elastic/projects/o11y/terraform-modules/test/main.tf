#######################################
### OpenTelemetry Operator
#######################################

resource "kubernetes_namespace" "opentelemetry_operator" {
  metadata {
    name = "opentelemetry-operator"
  }
}

resource "helm_release" "opentelemetry_operator" {
  repository = "${path.module}/helm/charts"
  chart      = "opentelemetry-operator"
  name       = "opentelemetry-operator"
  namespace  = kubernetes_namespace.opentelemetry_operator.metadata[0].name

  values = [
    file("${path.module}/helm/values/opentelemetry-operator.yaml"),
    templatefile("${path.module}/assets/opentelemetry_operator.yaml.tftpl", {
    }),
  ]
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
### Elastic Cloud on Kubernetes (ECK)
#######################################

resource "kubernetes_namespace" "elastic_system" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "elastic_operator" {
  repository = "${path.module}/helm/charts"
  chart      = "eck-operator"
  name       = "elastic-operator"
  namespace  = kubernetes_namespace.elastic_system.metadata[0].name

  values = [
    file("${path.module}/helm/values/eck-operator.yaml"),
    templatefile("${path.module}/assets/elastic_operator.yaml.tftpl", {
    }),
  ]
}

#######################################
### OpenTelemetry & Elastic stack
#######################################

module "test_elastic_stack" {
  source = "../../terraform-submodules/k8s-elastic-stack" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/k8s-elastic-stack/0.7.100.zip"

  kibana_domain = "kibana.gogke-test-7.damlys.dev"
  kibana_email  = "kibana@gogke-test-7.damlys.dev"
}

module "test_otel_collectors" {
  source = "../../terraform-submodules/k8s-otel-collectors" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/k8s-otel-collectors/0.7.100.zip"
  depends_on = [
    helm_release.opentelemetry_operator,
  ]

  elastic_apm_server_endpoint = module.test_elastic_stack.apm_server_endpoint
  elastic_apm_server_token    = module.test_elastic_stack.apm_server_token
}

module "test_prom_exporters" {
  source = "../../terraform-submodules/k8s-prom-exporters" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/k8s-prom-exporters/0.7.100.zip"

  blackbox_exporter_urls = [
    "https://kibana.gogke-test-7.damlys.dev/login",
    "https://stateful-kuard.gogke-test-7.damlys.dev/healthy",
    "https://stateless-kuard.gogke-test-7.damlys.dev/healthy",
  ]
}
