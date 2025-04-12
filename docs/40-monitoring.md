# Monitoring

## Grafana instances

- [grafana.gogke-test-2.damlys.dev](https://grafana.gogke-test-2.damlys.dev/explore)

## Kibana instances

- [kibana.gogke-test-2.damlys.dev](https://kibana.gogke-test-2.damlys.dev/app/discover) (password: `kubectl --context="gke_gogcp-test-2_europe-central2-a_gogke-test-2" --namespace="o11y-elasticsearch" get secrets "elasticsearch-es-elastic-user" --template="{{ .data.elastic | base64decode }}"`)
