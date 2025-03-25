# Secrets

```
$ kubectl \
  --context="gke_gogcp-test-2_europe-central2-a_gogke-test-2" \
  --namespace="vault-grafana" \
  create secret generic "smtp" \
  --from-literal="host=..." \
  --from-literal="username=..." \
  --from-literal="password=..."
```
