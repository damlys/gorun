# Vaults

## Kubernetes secrets

```
$ kubectl \
  --context="gke_gogcp-test-3_europe-central2-a_gogke-test-3" \
  --namespace="vault-kuard" \
  create secret generic "example" \
  --from-literal="username=exampleAdmin" \
  --from-literal="password=exampleSecret123"
```
