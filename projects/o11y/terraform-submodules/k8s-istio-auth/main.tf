resource "kubernetes_manifest" "istio_request_authentication" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "RequestAuthentication" # https://istio.io/latest/docs/reference/config/security/request_authentication/
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
    }
    spec = {
      selector = { matchLabels = var.kubernetes_service.spec[0].selector }

      jwtRules = [
        {
          issuer  = "https://accounts.google.com"
          jwksUri = "https://www.googleapis.com/oauth2/v3/certs"

          forwardOriginalToken = true
          outputClaimToHeaders = [
            {
              claim  = "email"
              header = "X-Forwarded-Email"
            },
            {
              claim  = "sub"
              header = "X-Forwarded-User"
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "istio_authorization_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy" # https://istio.io/latest/docs/reference/config/security/authorization-policy/
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
    }
    spec = {
      selector = { matchLabels = var.kubernetes_service.spec[0].selector }

      action = "ALLOW"
      rules = [
        {
          from = [{
            source = {
              requestPrincipals = ["https://accounts.google.com/*"]
            }
          }]
          when = [{
            key = "request.auth.claims[email]"
            values = [
              "*@gogcp-main-2.iam.gserviceaccount.com",
              "*@gogcp-prod-2.iam.gserviceaccount.com",
              "*@gogcp-test-2.iam.gserviceaccount.com",
              "damian.lysiak@gmail.com",
            ]
          }]
        },
        { # unprotected paths
          to = [{
            operation = {
              paths = [
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
