#######################################
### Elasticsearch
#######################################

resource "kubernetes_namespace" "elasticsearch" {
  metadata {
    name = "o11y-elasticsearch"
  }
}

resource "kubernetes_manifest" "elasticsearch" {
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1" # https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-elasticsearch-k8s-elastic-co-v1.html
    kind       = "Elasticsearch"
    metadata = {
      name      = "elasticsearch"
      namespace = kubernetes_namespace.elasticsearch.metadata[0].name
      labels = {
        "app.kubernetes.io/instance" = "elasticsearch"
        "app.kubernetes.io/name"     = "elasticsearch"
        "app.kubernetes.io/version"  = local.elastic_version
      }
      annotations = {
        "eck.k8s.elastic.co/license" = "basic"
      }
    }
    spec = yamldecode(templatefile("${path.module}/assets/elasticsearch_spec.yaml.tftpl", {
      elastic_version = local.elastic_version
    }))
  }

  field_manager {
    force_conflicts = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "${kubernetes_manifest.elasticsearch.manifest.metadata.name}-es-http"
    namespace = kubernetes_manifest.elasticsearch.manifest.metadata.namespace
  }
}

#######################################
### Kibana
#######################################

resource "kubernetes_namespace" "kibana" {
  metadata {
    name = "o11y-kibana"
  }

  timeouts {
    delete = "20m"
  }
}

resource "kubernetes_manifest" "kibana" {
  manifest = {
    apiVersion = "kibana.k8s.elastic.co/v1" # https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-kibana-k8s-elastic-co-v1.html
    kind       = "Kibana"
    metadata = {
      name      = "kibana"
      namespace = kubernetes_namespace.kibana.metadata[0].name
      labels = {
        "app.kubernetes.io/instance" = "kibana"
        "app.kubernetes.io/name"     = "kibana"
        "app.kubernetes.io/version"  = local.elastic_version
      }
      annotations = {
        "eck.k8s.elastic.co/license" = "basic"
      }
    }
    spec = yamldecode(templatefile("${path.module}/assets/kibana_spec.yaml.tftpl", {
      elastic_version = local.elastic_version

      kibana_domain = var.kibana_domain
      kibana_email  = var.kibana_email

      elasticsearch_name      = kubernetes_manifest.elasticsearch.manifest.metadata.name
      elasticsearch_namespace = kubernetes_manifest.elasticsearch.manifest.metadata.namespace
    }))
  }

  field_manager {
    force_conflicts = true
  }
}

data "kubernetes_service" "kibana" {
  metadata {
    name      = "${kubernetes_manifest.kibana.manifest.metadata.name}-kb-http"
    namespace = kubernetes_manifest.kibana.manifest.metadata.namespace
  }
}

module "kibana_gateway_http_route" {
  source = "../../../core/terraform-submodules/k8s-gateway-http-route" # "gcs::https://www.googleapis.com/storage/v1/gogcp-main-2-private-terraform-modules/gorun/core/k8s-gateway-http-route/0.3.100.zip"

  kubernetes_service = data.kubernetes_service.kibana

  domain            = var.kibana_domain
  service_port      = 5601
  container_port    = 5601
  health_check_path = "/login"
}

#######################################
### APM Server
#######################################

resource "kubernetes_namespace" "apm_server" {
  metadata {
    name = "o11y-apm-server"
  }
}

resource "kubernetes_manifest" "apm_server" {
  manifest = {
    apiVersion = "apm.k8s.elastic.co/v1" # https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-apm-k8s-elastic-co-v1.html
    kind       = "ApmServer"
    metadata = {
      name      = "apm-server"
      namespace = kubernetes_namespace.apm_server.metadata[0].name
      labels = {
        "app.kubernetes.io/instance" = "apm-server"
        "app.kubernetes.io/name"     = "apm-server"
        "app.kubernetes.io/version"  = local.elastic_version
      }
      annotations = {
        "eck.k8s.elastic.co/license" = "basic"
      }
    }
    spec = yamldecode(templatefile("${path.module}/assets/apm_server_spec.yaml.tftpl", {
      elastic_version = local.elastic_version

      elasticsearch_name      = kubernetes_manifest.elasticsearch.manifest.metadata.name
      elasticsearch_namespace = kubernetes_manifest.elasticsearch.manifest.metadata.namespace
      kibana_name             = kubernetes_manifest.kibana.manifest.metadata.name
      kibana_namespace        = kubernetes_manifest.kibana.manifest.metadata.namespace
    }))
  }

  field_manager {
    force_conflicts = true
  }
}

data "kubernetes_service" "apm_server" {
  metadata {
    name      = "${kubernetes_manifest.apm_server.manifest.metadata.name}-apm-http"
    namespace = kubernetes_manifest.apm_server.manifest.metadata.namespace
  }
}

data "kubernetes_secret" "apm_server_token" {
  metadata {
    name      = "${kubernetes_manifest.apm_server.manifest.metadata.name}-apm-token"
    namespace = kubernetes_manifest.apm_server.manifest.metadata.namespace
  }
}
