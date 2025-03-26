resource "helm_release" "this" {
  repository = path.module
  chart      = "manifest"
  version    = "0.0.0"

  namespace        = "helm-manifests"
  create_namespace = true

  name        = lower(trim(substr(replace(local.reference, "/[\\W]+/", "-"), -53, -1), "-"))
  description = local.reference

  set {
    name  = "manifest"
    type  = "string"
    value = yamlencode(var.manifest)
  }
}
