# Monitoring

## Kibana instances

- [kibana.gogke-test-7.damlys.dev](https://kibana.gogke-test-7.damlys.dev/app/discover) (password: `kubectl --context="gke_gogcp-test-7_europe-central2-a_gogke-test-7" --namespace="o11y-elasticsearch" get secrets "elasticsearch-es-elastic-user" --template="{{ .data.elastic | base64decode }}"`)
