data "helm_template" "debug2" {
  for_each = toset([
    "clusterMetrics",
    "hostMetrics",
    "kubeletMetrics",
    "kubernetesEvents",
    "logsCollection",
  ])

  chart = "../../third_party/helm/charts/opentelemetry-collector"

  name      = lower(each.value)
  namespace = "debug"
  values    = [file("${path.module}/debug/debug2.${each.value}.values.yaml")]
}

resource "local_file" "debug2" {
  for_each = data.helm_template.debug2

  filename = "${path.module}/debug/debug2.${each.key}.render.yaml"
  content  = data.helm_template.debug2[each.key].manifest
}
