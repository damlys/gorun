#######################################
### Elastic Cloud on Kubernetes (ECK)
#######################################

resource "kubernetes_namespace" "eck_operator" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "eck_operator" {
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
  source = "../../terraform-submodules/k8s-elk-stack"

  kibana_domain = "kibana.gogke-test-7.damlys.pl"
}

output "elasticsearch_username" {
  value = module.test_elk_stack.elasticsearch_username
}

output "elasticsearch_password" {
  value     = module.test_elk_stack.elasticsearch_password
  sensitive = true
}
