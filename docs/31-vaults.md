# Vaults

## Google Secret Manager secrets

- [gogcp-main-8](https://console.cloud.google.com/security/secret-manager?project=gogcp-main-8)

## Kubernetes secrets

```
$ kubectl \
  --context="gke_gogcp-test-8_europe-central2-a_gogke-test-8" \
  --namespace="vault-kuard" \
  create secret generic "example" \
  --from-literal="username=exampleAdmin" \
  --from-literal="password=exampleSecret123"
```
