locals {
  oauth2_client_id     = ""
  oauth2_client_secret = ""
  oauth2_redirect_uri  = "https://stateless-kuard.gogke-test-2.damlys.pl/oauth2/callback"
}

resource "helm_release" "stateless_kuard_oauth2_proxy" {
  repository = "oci://europe-central2-docker.pkg.dev/gogcp-main-2/external-helm-charts/gorun"
  chart      = "oauth2-proxy"
  version    = "7.12.6"

  name      = "oauth2-proxy-${data.kubernetes_service.stateless_kuard.metadata[0].name}"
  namespace = data.kubernetes_service.stateless_kuard.metadata[0].namespace

  values = [templatefile("${path.module}/assets/stateless_kuard_oauth2_proxy.yaml.tftpl", {
  })]
}

# resource "kubernetes_manifest" "stateless_kuard_istio_request_authentication" {
#   manifest = {
#     apiVersion = "security.istio.io/v1"
#     kind       = "RequestAuthentication" # https://istio.io/latest/docs/reference/config/security/request_authentication/
#     metadata = {
#       name      = data.kubernetes_service.stateless_kuard.metadata[0].name
#       namespace = data.kubernetes_service.stateless_kuard.metadata[0].namespace
#     }
#     spec = {
#       selector = { matchLabels = data.kubernetes_service.stateless_kuard.spec[0].selector }

#       jwtRules = [
#         {
#           issuer  = "https://accounts.google.com"
#           jwksUri = "https://www.googleapis.com/oauth2/v3/certs"
#         },
#       ]
#     }
#   }
# }

resource "kubernetes_manifest" "stateless_kuard_istio_authorization_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy" # https://istio.io/latest/docs/reference/config/security/authorization-policy/
    metadata = {
      name      = data.kubernetes_service.stateless_kuard.metadata[0].name
      namespace = data.kubernetes_service.stateless_kuard.metadata[0].namespace
    }
    spec = {
      selector = { matchLabels = data.kubernetes_service.stateless_kuard.spec[0].selector }

      action = "DENY"
      rules = [
        {
          from = [{
            source = {
              notRequestPrincipals = ["*"]
            }
          }]
        },
        {
          to = [{
            operation = {
              notPaths = [ # unprotected paths
                "/_healthy",
                "/_healthz",
                "/-/healthy",
                "/-/healthz",
                "/api/healthy",
                "/api/healthz",
                "/healthy",
                "/healthz",
              ]
            }
          }]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "stateless_kuard_gateway_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute" # https://gateway-api.sigs.k8s.io/reference/spec/#gateway.networking.k8s.io/v1.HTTPRoute
    metadata = {
      name      = data.kubernetes_service.stateless_kuard.metadata[0].name
      namespace = data.kubernetes_service.stateless_kuard.metadata[0].namespace
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = "gke-gateway"
        namespace   = "gke-gateway"
        sectionName = "https-wildcard"
      }]
      hostnames = ["stateless-kuard.${var.platform_domain}"]
      rules = [
        {
          matches = [{
            path = {
              type  = "PathPrefix"
              value = "/oauth2"
            }
          }]
          backendRefs = [{
            group     = ""
            kind      = "Service"
            name      = helm_release.stateless_kuard_oauth2_proxy.name
            namespace = helm_release.stateless_kuard_oauth2_proxy.namespace
            port      = 80
          }]
        },
        {
          matches = [{
            path = {
              type  = "PathPrefix"
              value = "/"
            }
          }]
          filters = [{
            type = "RequestHeaderModifier"
            requestHeaderModifier = {
              add = [
                {
                  name  = "X-Forwarded-Email"
                  value = "{Request.auth.claims[email]}"
                },
                {
                  name  = "X-Forwarded-User"
                  value = "{Request.auth.claims[sub]}"
                },
              ]
            }
          }]
          backendRefs = [{
            group     = ""
            kind      = "Service"
            name      = data.kubernetes_service.stateless_kuard.metadata[0].name
            namespace = data.kubernetes_service.stateless_kuard.metadata[0].namespace
            port      = 80
          }]
        },
      ]
    }
  }
}
