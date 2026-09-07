# Vaults

## Google Secret Manager secrets

- [gogcp-main-9](https://console.cloud.google.com/security/secret-manager?project=gogcp-main-9)

## Kubernetes secrets

```
$ kubectl \
  --context="gke_gogcp-test-9_europe-central2-a_gogke-test-9" \
  --namespace="vault-kuard" \
  create secret generic "example" \
  --from-literal="username=exampleAdmin" \
  --from-literal="password=exampleSecret123"
```
