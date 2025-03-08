#######################################
### cert-manager
#######################################

resource "helm_release" "cert_manager_issuers" {
  depends_on = [
    helm_release.cert_manager,
  ]

  # repository = "oci://europe-central2-docker.pkg.dev/gogke-main-0/private-helm-charts/gogke/core"
  chart = "../../helm-charts/cert-manager-issuers" # "cert-manager-issuers"
  # version = "0.2.0"

  name      = "cert-manager-issuers"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name
}
