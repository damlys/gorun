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

  values = [templatefile("${path.module}/assets/loki/values.yaml.tftpl", {
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

  values = [templatefile("${path.module}/assets/mimir/values.yaml.tftpl", {
  })]
}

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

  values = [templatefile("${path.module}/assets/tempo/values.yaml.tftpl", {
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

  values = [templatefile("${path.module}/assets/grafana/values.yaml.tftpl", {
    grafana_domain = var.grafana_domain

    loki_name      = helm_release.loki.name
    loki_namespace = helm_release.loki.namespace

    mimir_name      = helm_release.mimir.name
    mimir_namespace = helm_release.mimir.namespace

    tempo_name      = helm_release.tempo.name
    tempo_namespace = helm_release.tempo.namespace
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
