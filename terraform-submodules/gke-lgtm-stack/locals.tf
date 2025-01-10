locals {
  loki_entrypoint  = "http://${data.helm_template.loki.name}-gateway.${data.helm_template.loki.namespace}.svc:80"
  mimir_entrypoint = "http://${data.helm_template.mimir.name}-nginx.${data.helm_template.mimir.namespace}.svc:80"
  tempo_entrypoint = "http://${data.helm_template.tempo.name}-query-frontend.${data.helm_template.tempo.namespace}.svc:3100"
}
