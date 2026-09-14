resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "workstation-${var.workstation_name}"
  }

  lifecycle {
    prevent_destroy = true
  }

  timeouts {
    delete = "20m" # it takes about 10 minutes to delete a GKE gateway route (servicenetworkendpointgroups.networking.gke.io)
  }
}

#######################################
### Docker-in-Docker (DinD)
#######################################

resource "kubernetes_service_v1" "dind" {
  metadata {
    name      = "dind"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.dind_metadata_labels
  }
  spec {
    selector                    = local.dind_selector_labels
    type                        = "ClusterIP"
    cluster_ip                  = "None" # headless service
    publish_not_ready_addresses = true
    port {
      name        = "dind-tcp"
      port        = 2375
      protocol    = "TCP"
      target_port = "dind-tcp"
    }
  }
}

resource "kubernetes_service_account_v1" "dind" {
  metadata {
    name      = "dind"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.dind_metadata_labels
  }
}

resource "kubernetes_stateful_set_v1" "dind" {
  metadata {
    name      = "dind"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.dind_metadata_labels
  }
  spec {
    service_name = kubernetes_service_v1.dind.metadata[0].name
    replicas     = 1
    selector {
      match_labels = local.dind_selector_labels
    }
    template {
      metadata {
        labels = local.dind_metadata_labels
      }
      spec {
        service_account_name = kubernetes_service_account_v1.dind.metadata[0].name
        container {
          name  = "docker"
          image = "docker:dind"
          env {
            name  = "DOCKER_TLS_CERTDIR"
            value = ""
          }
          volume_mount {
            name       = "docker-data"
            mount_path = "/var/lib/docker"
          }
          port {
            name           = "dind-tcp"
            container_port = 2375
            protocol       = "TCP"
          }
          resources {
            requests = {
              cpu    = "1m"
              memory = "1Mi"
            }
          }
          security_context { # container security context
            privileged = true
          }
        }
        security_context { # pod security context
        }
        volume {
          name = "docker-data"
          empty_dir {
          }
        }
      }
    }
  }
}

#######################################
### Code editor
#######################################

resource "kubernetes_service_v1" "code" {
  metadata {
    name      = "code"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.code_metadata_labels
  }
  spec {
    selector                    = local.code_selector_labels
    type                        = "ClusterIP"
    cluster_ip                  = "None" # headless service
    publish_not_ready_addresses = true
    port {
      name        = "code-http"
      port        = 8080
      protocol    = "TCP"
      target_port = "code-http"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg"],
      metadata[0].annotations["cloud.google.com/neg-status"],
    ]
  }
}

resource "kubernetes_service_account_v1" "code" {
  metadata {
    name      = "code"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.code_metadata_labels
  }
  automount_service_account_token = false
}

resource "kubernetes_stateful_set_v1" "code" {
  metadata {
    name      = "code"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.code_metadata_labels
  }
  spec {
    service_name = kubernetes_service_v1.code.metadata[0].name
    replicas     = 1
    selector {
      match_labels = local.code_selector_labels
    }
    template {
      metadata {
        labels = local.code_metadata_labels
      }
      spec {
        service_account_name            = kubernetes_service_account_v1.code.metadata[0].name
        automount_service_account_token = false
        container {
          name    = "code-server"
          image   = local.workstation_image
          command = ["code-server"]
          args    = ["--auth=password"]
          env {
            name  = "PASSWORD"
            value = "Secret123"
          }
          env {
            name  = "DOCKER_HOST"
            value = local.dind_host
          }
          volume_mount {
            name       = "code-home"
            mount_path = "/home/code"
          }
          working_dir = "/home/code"
          port {
            name           = "code-http"
            container_port = 8080
            protocol       = "TCP"
          }
          startup_probe {
            http_get {
              port = "code-http"
              path = "/healthz"
            }
          }
          readiness_probe {
            http_get {
              port = "code-http"
              path = "/healthz"
            }
          }
          liveness_probe {
            http_get {
              port = "code-http"
              path = "/healthz"
            }
          }
          resources {
            requests = {
              # PROD cpu    = "2000m"
              # PROD memory = "1Gi"
              cpu    = "1m"
              memory = "1Mi"
            }
            # PROD limits = {
            #   cpu    = ""
            #   memory = ""
            # }
          }
          security_context { # container security context
            run_as_non_root           = true
            read_only_root_filesystem = false
            run_as_user               = 1111 # code
            run_as_group              = 1111 # code
          }
        }
        security_context { # pod security context
          fs_group               = 1111
          fs_group_change_policy = "OnRootMismatch"
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "code-home"
      }
      spec {
        storage_class_name = "standard-rwo"
        access_modes       = ["ReadWriteOnce"]
        resources {
          requests = {
            # PROD storage = "100Gi"
            storage = "10Gi"
          }
        }
      }
    }
    persistent_volume_claim_retention_policy {
      when_scaled  = "Retain"
      when_deleted = "Retain"
    }
  }
}

module "code_gateway_http_route" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = kubernetes_service_v1.code
  health_check_path  = "/healthz"

  domain = var.code_domain
}

#######################################
### IAM
#######################################

resource "kubernetes_cluster_role_binding_v1" "owners" {
  count = length(var.iam_owners) > 0 ? 1 : 0

  metadata {
    name = "custom:workstation-owners:${kubernetes_namespace_v1.this.metadata[0].name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workstation-owner:cluster"
  }
  dynamic "subject" {
    for_each = var.iam_owners

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}

resource "kubernetes_role_binding_v1" "owners" {
  count = length(var.iam_owners) > 0 ? 1 : 0

  metadata {
    name      = "custom:workstation-owners"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "custom:workstation-owner:namespace"
  }
  dynamic "subject" {
    for_each = var.iam_owners

    content {
      api_group = "rbac.authorization.k8s.io"
      kind      = startswith(subject.value, "user:") ? "User" : startswith(subject.value, "group:") ? "Group" : startswith(subject.value, "serviceAccount:") ? "User" : null
      name      = split(":", subject.value)[1]
      namespace = "gke-security-groups"
    }
  }
}
