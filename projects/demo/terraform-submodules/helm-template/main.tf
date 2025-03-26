data "helm_template" "this" {
  repository = var.repository
  chart      = var.chart
  version    = var.version_

  namespace = var.namespace
  name      = var.name
  values    = var.values
}

resource "kubernetes_manifest" "this" {
  for_each = {
    for m in [
      for n in split("\n---\n", data.helm_template.this.manifest)
      : yamldecode(n)
    ]
    : "${m.apiVersion}/${m.kind}/${try(m.metadata.namespace, "-")}/${m.metadata.name}" => m
  }
  manifest = each.value

  field_manager {
    force_conflicts = true
  }
}
