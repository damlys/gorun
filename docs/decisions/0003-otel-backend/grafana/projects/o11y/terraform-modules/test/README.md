This module deploys observability tools to the test platform.

```
$ terraform apply -target=module.grafana_vault
$ kubectl \
    --context="gke_gogcp-test-7_europe-central2-a_gogke-test-7" \
    --namespace="vault-grafana" \
    create secret generic "smtp" \
    --from-literal="host=email-smtp.eu-central-1.amazonaws.com:465" \
    --from-literal="username=..." \
    --from-literal="password=..."

$ terraform apply -target=helm_release.opentelemetry_operator
$ terraform apply
```
