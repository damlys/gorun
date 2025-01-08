# data "helm_template" "loki" {}
# resource "local_file" "loki" {
#   filename = "${path.module}/debug.loki.yaml"
#   content  = data.helm_template.loki.manifest
# }

# data "helm_template" "mimir" {}
# resource "local_file" "mimir" {
#   filename = "${path.module}/debug.mimir.yaml"
#   content  = data.helm_template.mimir.manifest
# }

# data "helm_template" "tempo" {}
# resource "local_file" "tempo" {
#   filename = "${path.module}/debug.tempo.yaml"
#   content  = data.helm_template.tempo.manifest
# }
