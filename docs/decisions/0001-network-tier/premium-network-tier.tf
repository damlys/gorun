#######################################
### projects/core/terraform-submodules/gcp-project
#######################################

resource "google_compute_project_default_network_tier" "this" { # console.cloud.google.com/net-tier/tiers/details
  project = google_project.this.project_id

  network_tier = "PREMIUM"
}

#######################################
### projects/core/terraform-submodules/gke-platform
#######################################

resource "google_compute_global_address" "ingress_internet" { # console.cloud.google.com/networking/addresses/list
  project = var.google_project.project_id
  name    = "${var.platform_name}-ingress-internet"

  address_type = "EXTERNAL"
}

resource "google_dns_managed_zone" "ingress_internet" { # console.cloud.google.com/net-services/dns/zones
  project  = var.google_project.project_id
  name     = "${var.platform_name}-ingress-internet"
  dns_name = "${var.platform_domain}."

  visibility = "public"

  dnssec_config {
    state = var.platform_dnssec_enabled ? "on" : "off"
  }

  # override default description
  description = "-"
}

data "google_dns_keys" "ingress_internet" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.id
}

resource "google_dns_record_set" "ingress_internet" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.name

  for_each = toset([google_dns_managed_zone.ingress_internet.dns_name, "*.${google_dns_managed_zone.ingress_internet.dns_name}"])
  name     = each.value
  type     = "A"
  ttl      = 300
  rrdatas  = [google_compute_global_address.ingress_internet.address]
}

resource "google_certificate_manager_dns_authorization" "ingress_internet" {
  project  = var.google_project.project_id
  name     = "${var.platform_name}-ingress-internet"
  location = "global"

  domain = var.platform_domain
}

resource "google_dns_record_set" "ingress_internet_dns_authorization" {
  project      = var.google_project.project_id
  managed_zone = google_dns_managed_zone.ingress_internet.name

  name    = google_certificate_manager_dns_authorization.ingress_internet.dns_resource_record[0].name
  type    = google_certificate_manager_dns_authorization.ingress_internet.dns_resource_record[0].type
  ttl     = 300
  rrdatas = [google_certificate_manager_dns_authorization.ingress_internet.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "ingress_internet" { # console.cloud.google.com/security/ccm/list/certificates
  project  = var.google_project.project_id
  name     = "${var.platform_name}-ingress-internet"
  location = "global"

  scope = "DEFAULT"

  managed {
    domains            = [var.platform_domain, "*.${var.platform_domain}"]
    dns_authorizations = [google_certificate_manager_dns_authorization.ingress_internet.id]
  }
}

resource "google_certificate_manager_certificate_map" "ingress_internet" {
  project = var.google_project.project_id
  name    = "${var.platform_name}-ingress-internet"
}

resource "google_certificate_manager_certificate_map_entry" "ingress_internet" {
  project = var.google_project.project_id
  map     = google_certificate_manager_certificate_map.ingress_internet.name
  name    = "${var.platform_name}-ingress-internet-${substr(sha256(each.value), 0, 5)}"

  for_each     = toset(google_certificate_manager_certificate.ingress_internet.managed[0].domains)
  hostname     = each.value
  certificates = [google_certificate_manager_certificate.ingress_internet.id]
}

resource "kubernetes_namespace" "gke_gateway" {
  depends_on = [
    google_container_cluster.this,
  ]

  metadata {
    name = "gke-gateway"
  }
}

resource "kubernetes_namespace" "gke_gateway_redirect" {
  depends_on = [
    google_container_cluster.this,
  ]

  metadata {
    name = "gke-gateway-redirect"
    labels = {
      name = "gke-gateway-redirect"
    }
  }
}

resource "kubernetes_manifest" "gke_gateway" { # console.cloud.google.com/net-services/loadbalancing/list/loadBalancers
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      namespace = kubernetes_namespace.gke_gateway.metadata[0].name
      name      = "gke-gateway"
      annotations = {
        "networking.gke.io/certmap" = google_certificate_manager_certificate_map.ingress_internet.name
      }
    }
    spec = {
      gatewayClassName = "gke-l7-global-external-managed" # global external Application Load Balancer
      listeners = [
        {
          name     = "http"
          port     = 80
          protocol = "HTTP"
          allowedRoutes = {
            kinds = [{
              kind = "HTTPRoute"
            }]
            namespaces = {
              from     = "Selector"
              selector = { matchLabels = kubernetes_namespace.gke_gateway_redirect.metadata[0].labels }
            }
          }
        },
        {
          name     = "https"
          port     = 443
          protocol = "HTTPS"
          allowedRoutes = {
            kinds = [{
              kind = "HTTPRoute"
            }]
            namespaces = {
              from = "All"
            }
          }
        },
      ]
      addresses = [{
        type  = "NamedAddress"
        value = google_compute_global_address.ingress_internet.name
      }]
    }
  }
}

resource "kubernetes_manifest" "gke_gateway_redirect_http_to_https" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      namespace = kubernetes_namespace.gke_gateway_redirect.metadata[0].name
      name      = "http-to-https"
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        namespace   = kubernetes_manifest.gke_gateway.manifest.metadata.namespace
        name        = kubernetes_manifest.gke_gateway.manifest.metadata.name
        sectionName = "http"
      }]
      rules = [{
        filters = [{
          type = "RequestRedirect"
          requestRedirect = {
            scheme = "https"
          }
        }]
      }]
    }
  }
}

#######################################
### projects/core/terraform-submodules/gke-gateway-route
#######################################

resource "kubernetes_manifest" "http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = var.kubernetes_service.metadata[0].name
      namespace = var.kubernetes_service.metadata[0].namespace
    }
    spec = {
      parentRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = "gke-gateway"
        namespace   = "gke-gateway"
        sectionName = "https"
      }]
      hostnames = [var.domain]
      rules = [{
        backendRefs = [{
          group     = ""
          kind      = "Service"
          name      = var.kubernetes_service.metadata[0].name
          namespace = var.kubernetes_service.metadata[0].namespace
          port      = var.service_port
        }]
      }]
    }
  }
}
