# External resources

## Helm charts

```
$ ./scripts/ext download-helm-charts "projects/demo/terraform-submodules/kuard"
```

Sources:

- https://github.com/cert-manager/cert-manager/tree/master/deploy/charts
- https://github.com/grafana/helm-charts
- https://github.com/open-telemetry/opentelemetry-helm-charts
- https://github.com/prometheus-community/helm-charts
- https://github.com/vmware-tanzu/helm-charts

```
$ helm repo add grafana https://grafana.github.io/helm-charts
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
```
