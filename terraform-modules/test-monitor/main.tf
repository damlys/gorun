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

  values = [file("${path.module}/assets/helm_release.opentelemetry_operator.yaml")]
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
