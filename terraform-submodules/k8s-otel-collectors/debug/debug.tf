data "helm_template" "debug" {
  for_each = toset([
    "clusterMetrics",
    "hostMetrics",
    "kubeletMetrics",
    "kubernetesEvents",
    "logsCollection",
  ])

  repository = null
  chart      = "../../third_party/helm/charts/opentelemetry-collector" # TODO
  version    = null

  name      = lower(each.value)
  namespace = "debug"
  values    = [file("${path.module}/debug/values.${each.value}.yaml")]
}

resource "local_file" "debug" {
  for_each = data.helm_template.debug

  filename = "${path.module}/debug/render.${each.key}.yaml"
  content  = data.helm_template.debug[each.key].manifest
}
