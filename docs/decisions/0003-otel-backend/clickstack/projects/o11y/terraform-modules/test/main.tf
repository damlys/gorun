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

#######################################
### OpenTelemetry & ClickStack
#######################################

module "test_clickstack" {
  source = "../../terraform-submodules/gke-clickstack" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/gke-clickstack/0.7.100.zip"

  google_project = data.google_project.this

  hyperdx_domain = "hyperdx.gogke-test-7.damlys.dev"
}

module "test_otel_collectors" {
  source = "../../terraform-submodules/k8s-otel-collectors" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/k8s-otel-collectors/0.7.100.zip"
  depends_on = [
    helm_release.opentelemetry_operator,
  ]

  clickstack_endpoint = module.test_clickstack.clickstack_endpoint
  clickstack_api_key  = module.test_clickstack.clickstack_api_key
}

module "test_prom_exporters" {
  source = "../../terraform-submodules/k8s-prom-exporters" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-7-private-terraform-modules/gorun/o11y/k8s-prom-exporters/0.7.100.zip"

  blackbox_exporter_urls = [
    "https://hyperdx.gogke-test-7.damlys.dev/api/health",
    "https://stateful-kuard.gogke-test-7.damlys.dev/healthy",
    "https://stateless-kuard.gogke-test-7.damlys.dev/healthy",
  ]
}
