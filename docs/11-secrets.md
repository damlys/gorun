# Secrets

```
$ kubectl --namespace="vault-grafana" create secret generic "smtp" \
  --from-literal="host=..." \
  --from-literal="username=..." \
  --from-literal="password=..."
```
