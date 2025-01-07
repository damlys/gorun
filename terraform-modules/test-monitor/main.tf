#######################################
### OpenTelemetry Operator
#######################################

resource "kubernetes_namespace" "otel_operator" {
  metadata {
    name = "opentelemetry-operator"
  }
}

resource "helm_release" "otel_operator" {
  # TODO
  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-operator"
  version    = null

  namespace = kubernetes_namespace.otel_operator.metadata[0].name
  name      = "opentelemetry-operator"
  values    = [file("${path.module}/assets/otel_operator.yaml")]
}

#######################################
### Elastic Cloud on Kubernetes (ECK)
#######################################

resource "kubernetes_namespace" "eck_operator" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "eck_operator" {
  # TODO
  repository = null
  chart      = "../../third_party/helm/charts/eck-operator"
  version    = null

  namespace = kubernetes_namespace.eck_operator.metadata[0].name
  name      = "elastic-operator"
}

#######################################
### ...
#######################################

module "test_elk_stack" {
  source = "../../terraform-submodules/k8s-elk-stack" # TODO

  kibana_domain = "kibana.gogke-test-7.damlys.pl"
}
