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
### Metricbeat
#######################################

resource "kubernetes_namespace" "metricbeat" {
  metadata {
    name = "o11y-metricbeat"
  }
}

resource "kubernetes_manifest" "metricbeat" {
  manifest = {
    apiVersion = "beat.k8s.elastic.co/v1beta1" # https://www.elastic.co/guide/en/cloud-on-k8s/2.16/k8s-api-beat-k8s-elastic-co-v1beta1.html
    kind       = "Beat"
    metadata = {
      name      = "metricbeat"
      namespace = kubernetes_namespace.metricbeat.metadata[0].name
      labels = {
        "app.kubernetes.io/instance" = "metricbeat"
        "app.kubernetes.io/name"     = "metricbeat"
        "app.kubernetes.io/version"  = local.elastic_version
      }
      annotations = {
        "eck.k8s.elastic.co/license" = "basic"
      }
    }
    spec = yamldecode(templatefile("${path.module}/assets/metricbeat_spec.yaml.tftpl", {
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
