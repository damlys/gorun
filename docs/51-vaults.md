# Vaults

## Kubernetes secrets

```
$ kubectl \
  --context="gke_gogcp-test-2_europe-central2-a_gogke-test-2" \
  --namespace="vault-kuard" \
  create secret generic "example" \
  --from-literal="username=exampleAdmin" \
  --from-literal="password=exampleSecret123"
```
