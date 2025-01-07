#######################################
### Tempo
#######################################

resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "lgtm-tempo"
  }
}

resource "helm_release" "tempo" {
  chart = "${path.module}/charts/tempo-distributed"

  name      = "tempo"
  namespace = kubernetes_namespace.tempo.metadata[0].name

  values = [templatefile("${path.module}/assets/tempo.yaml.tftpl", {
  })]
}

#######################################
### Mimir
#######################################

resource "kubernetes_namespace" "mimir" {
  metadata {
    name = "lgtm-mimir"
  }
}

resource "helm_release" "mimir" {
  chart = "${path.module}/charts/mimir-distributed"

  name      = "mimir"
  namespace = kubernetes_namespace.mimir.metadata[0].name

  values = [templatefile("${path.module}/assets/mimir.yaml.tftpl", {
  })]
}

#######################################
### Loki
#######################################

resource "kubernetes_namespace" "loki" {
  metadata {
    name = "lgtm-loki"
  }
}

resource "helm_release" "loki" {
  chart = "${path.module}/charts/loki"

  name      = "loki"
  namespace = kubernetes_namespace.loki.metadata[0].name

  values = [templatefile("${path.module}/assets/loki.yaml.tftpl", {
  })]
}

#######################################
### Grafana
#######################################

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "lgtm-grafana"
  }
}

resource "helm_release" "grafana" {
  chart = "${path.module}/charts/grafana"

  name      = "grafana"
  namespace = kubernetes_namespace.grafana.metadata[0].name

  values = [templatefile("${path.module}/assets/grafana.yaml.tftpl", {
    grafana_domain = var.grafana_domain,
  })]
}

#######################################
### OpenTelemetry Collector
#######################################

resource "kubernetes_namespace" "otelcol" {
  metadata {
    name = "lgtm-otelcol"
  }
}
