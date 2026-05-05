Terraform module: Kubernetes Up and Running Demo

```
$ terraform apply -target=module.vault
$ kubectl \
    --context="gke_gogcp-test-8_europe-central2-a_gogke-test-8" \
    --namespace="vault-kuard" \
    create secret generic "example" \
    --from-literal="username=example" \
    --from-literal="password=example123"

$ terraform apply
```
