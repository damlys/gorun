locals {
  postgres_host       = "${helm_release.grafana_postgres.name}-0.${helm_release.grafana_postgres.name}-headless.${helm_release.grafana_postgres.namespace}.svc.cluster.local"
  clickhouse_host     = "${helm_release.clickhouse.name}-0.${helm_release.clickhouse.name}-headless.${helm_release.clickhouse.namespace}.svc.cluster.local"
  clickhouse_endpoint = "tcp://${local.clickhouse_host}:9000"
}

data "kubernetes_secret" "grafana_smtp" {
  metadata {
    name      = "smtp"
    namespace = "vault-grafana"
  }
}
