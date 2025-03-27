locals {
  reference = "${var.manifest.apiVersion}/${var.manifest.kind}/${try(var.manifest.metadata.namespace, "-")}/${var.manifest.metadata.name}"
}
