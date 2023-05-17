resource "kubernetes_config_map" "config_envs" {
  metadata {
    name      = "${var.name}-config-envs"
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  data = var.config_envs
}

resource "kubernetes_secret" "config_envs" {
  metadata {
    name      = "${var.name}-config-envs"
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  data = var.secret_config_envs
}

resource "kubernetes_config_map" "config_files" {
  metadata {
    name      = "${var.name}-config-files"
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  data = var.config_files
}

resource "kubernetes_secret" "config_files" {
  metadata {
    name      = "${var.name}-config-files"
    namespace = var.namespace
    labels    = local.metadata_labels
  }
  data = var.secret_config_files
}

resource "kubernetes_service_account" "general" {
  metadata {
    name      = "${var.name}-general"
    namespace = var.namespace
    labels = merge(local.metadata_labels, {
      "app.kubernetes.io/component" = "general"
    })
  }
}

resource "kubernetes_deployment" "http_server" {
  metadata {
    name      = "${var.name}-http-server"
    namespace = var.namespace
    labels = merge(local.metadata_labels, {
      "app.kubernetes.io/component" = "http-server"
    })
  }
  spec {
    replicas = var.min_http_server_replicas
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = merge(local.selector_labels, {
        "app.kubernetes.io/component" = "http-server"
      })
    }
    template {
      metadata {
        labels = merge(local.metadata_labels, {
          "app.kubernetes.io/component" = "http-server"
        })
        annotations = {
          "checksum/configs" = local.configs_checksum
        }
      }
      spec {
        service_account_name = kubernetes_service_account.general.metadata[0].name
        container {
          name  = "http-server"
          image = "${var.image_repository}:${var.image_tag}"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.config_envs.metadata[0].name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.config_envs.metadata[0].name
            }
          }
          volume_mount {
            name       = "config-files"
            mount_path = "/run/secrets/kuard"
            read_only  = true
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
          resources {
            requests = {
              cpu    = "1m"
              memory = "1M"
            }
            limits = {
              cpu    = "250m"
              memory = "256M"
            }
          }
        }
        volume {
          name = "config-files"
          projected {
            sources {
              config_map {
                name = kubernetes_config_map.config_files.metadata[0].name
              }
            }
            sources {
              secret {
                name = kubernetes_secret.config_files.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec[0].replicas,
    ]
  }
}

resource "kubernetes_manifest" "http_server_pod_monitoring" {
  # https://github.com/GoogleCloudPlatform/prometheus-engine/blob/v0.2.3/doc/api.md#podmonitoring
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "${var.name}-http-server"
      namespace = var.namespace
      labels = merge(local.metadata_labels, {
        "app.kubernetes.io/component" = "http-server"
      })
    }
    spec = {
      selector = {
        matchLabels = merge(local.selector_labels, {
          "app.kubernetes.io/component" = "http-server"
        })
      }
      endpoints = [{
        port     = "http"
        path     = "/metrics"
        interval = "30s"
      }]
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "http_server" {
  metadata {
    name      = "${var.name}-http-server"
    namespace = var.namespace
    labels = merge(local.metadata_labels, {
      "app.kubernetes.io/component" = "http-server"
    })
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.http_server.metadata[0].name
    }
    min_replicas = var.min_http_server_replicas
    max_replicas = var.max_http_server_replicas
  }
}

resource "kubernetes_service" "http_server" {
  metadata {
    name      = "${var.name}-http-server"
    namespace = var.namespace
    labels = merge(local.metadata_labels, {
      "app.kubernetes.io/component" = "http-server"
    })
  }
  spec {
    type     = "ClusterIP"
    selector = kubernetes_deployment.http_server.spec[0].selector[0].match_labels
    port {
      name        = "http"
      port        = 8080
      protocol    = "TCP"
      target_port = "http"
    }
  }
}
