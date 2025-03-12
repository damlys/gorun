```
$ terraform apply -target=helm_release.opentelemetry_operator
$ terraform apply -target=helm_release.istio_base
$ terraform apply -target=module.test_lgtm_stack.helm_release.grafana
$ terraform apply
```
