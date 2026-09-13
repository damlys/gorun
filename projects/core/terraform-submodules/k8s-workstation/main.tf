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
### Code editor
#######################################

resource "kubernetes_service_v1" "code" {
  metadata {
    name      = "code-headless"
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
        enable_service_links            = false
        container {
          name  = "code-server"
          image = local.devcontainer
          command = [
            "code-server",
          ]
          args = [
            "--bind-addr=0.0.0.0:8080",
            "--auth=password",
          ]
          env {
            name  = "PASSWORD"
            value = "Secret123"
          }
          env {
            name  = "EDITOR"
            value = "code --wait"
          }
          volume_mount {
            name       = "code-home"
            mount_path = "/home/code"
          }
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
              cpu    = "1m"
              memory = "1Mi"
            }
            limits = {
              cpu    = "2000m"
              memory = "1Gi"
            }
          }
          security_context { # container security context
            run_as_non_root           = true
            read_only_root_filesystem = false
            run_as_user               = 1111
            run_as_group              = 1111
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
            storage = "10Gi"
          }
        }
      }
    }
  }
}

module "code_http_route" {
  # PROD source = "gcs::https://www.googleapis.com/storage/v1/gogcp-main-9-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.9.100.zip"
  source = "../../../core/terraform-submodules/k8s-gateway-http-route"

  kubernetes_service = kubernetes_service_v1.code
  health_check_path  = "/healthz"

  domain = var.workstation_domain
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
