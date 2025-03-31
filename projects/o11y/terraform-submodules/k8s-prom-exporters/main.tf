#######################################
### kube-state-metrics
#######################################

resource "kubernetes_namespace" "kube_state_metrics" {
  metadata {
    name = "o11y-kube-state-metrics"
  }
}

resource "helm_release" "kube_state_metrics" {
  repository = "${path.module}/helm/charts"
  chart      = "kube-state-metrics"
  name       = "kube-state-metrics"
  namespace  = kubernetes_namespace.kube_state_metrics.metadata[0].name

  values = [
    file("${path.module}/helm/values/kube-state-metrics.yaml"),
    templatefile("${path.module}/assets/kube_state_metrics.yaml.tftpl", {
    }),
  ]
}

#######################################
### prometheus-node-exporter
#######################################

resource "kubernetes_namespace" "node_exporter" {
  metadata {
    name = "o11y-prometheus-node-exporter"
  }
}

resource "helm_release" "node_exporter" {
  repository = "${path.module}/helm/charts"
  chart      = "prometheus-node-exporter"
  name       = "prometheus-node-exporter"
  namespace  = kubernetes_namespace.node_exporter.metadata[0].name

  values = [
    file("${path.module}/helm/values/prometheus-node-exporter.yaml"),
    templatefile("${path.module}/assets/node_exporter.yaml.tftpl", {
    }),
  ]
}

#######################################
### prometheus-blackbox-exporter
#######################################

resource "kubernetes_namespace" "blackbox_exporter" {
  metadata {
    name = "o11y-prometheus-blackbox-exporter"
  }
}

resource "helm_release" "blackbox_exporter" {
  repository = "${path.module}/helm/charts"
  chart      = "prometheus-blackbox-exporter"
  name       = "prometheus-blackbox-exporter"
  namespace  = kubernetes_namespace.blackbox_exporter.metadata[0].name

  values = [
    file("${path.module}/helm/values/prometheus-blackbox-exporter.yaml"),
    templatefile("${path.module}/assets/blackbox_exporter.yaml.tftpl", {
    }),
  ]
}
