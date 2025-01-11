#######################################
### Prometheus Operator
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
  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-operator" # TODO
  version    = null

  name      = "opentelemetry-operator"
  namespace = kubernetes_namespace.opentelemetry_operator.metadata[0].name

  values = [file("${path.module}/assets/opentelemetry_operator.yaml")]
}

#######################################
### ...
#######################################

module "test_lgtm_stack" {
  source = "../../terraform-submodules/gke-lgtm-stack" # TODO

  google_project           = data.google_project.this
  google_container_cluster = data.google_container_cluster.this

  grafana_domain = "grafana.gogke-test-7.damlys.pl"
}

module "test_otel_collectors" {
  source = "../../terraform-submodules/k8s-otel-collectors" # TODO

  loki_entrypoint  = module.test_lgtm_stack.loki_entrypoint
  mimir_entrypoint = module.test_lgtm_stack.mimir_entrypoint
  tempo_entrypoint = module.test_lgtm_stack.tempo_entrypoint
}
