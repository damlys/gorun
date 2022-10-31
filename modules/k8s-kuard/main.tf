resource "kubernetes_deployment" "http_server" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  spec {
    selector {
      match_labels = local.selector_labels
    }
    replicas = local.min_replicas
    template {
      metadata {
        labels = local.metadata_labels
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "http"
          "prometheus.io/path"   = "/metrics"
        }
      }
      spec {
        service_account_name = var.service_account
        container {
          name  = "http-server"
          image = "${local.image_name}:${local.image_tag}"
          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "400m"
              memory = "512Mi"
            }
          }
          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }
          readiness_probe {
            http_get {
              port = "http"
              path = "/ready"
            }
          }
          liveness_probe {
            http_get {
              port = "http"
              path = "/healthy"
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec.0.replicas
    ]
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "http_server" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  spec {
    min_replicas = local.min_replicas
    max_replicas = local.max_replicas
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.http_server.metadata[0].name
    }
    target_cpu_utilization_percentage = 10
  }
}

resource "kubernetes_service" "http_server" {
  depends_on = [
    kubernetes_deployment.http_server,
  ]
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  spec {
    type = "ClusterIP"
    port {
      target_port = "http"
      name        = "http"
      port        = 80
      protocol    = "TCP"
    }
    selector = local.selector_labels
  }
}

resource "kubernetes_ingress_v1" "http_server" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  spec {
    rule {
      host = var.host
      http {
        path {
          path      = var.path
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.http_server.metadata[0].name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
    tls {
      hosts       = [var.host]
      secret_name = local.tls_secret_name
    }
  }
}
