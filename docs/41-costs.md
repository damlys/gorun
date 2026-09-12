# Costs

## Google Cloud Platform billing accounts

- [011D45-32FBBB-49E61D](https://console.cloud.google.com/billing/011D45-32FBBB-49E61D/manage)

## Kubernetes resources

Deleting and recreating non-production Kubernetes nodes:

```
$ ./scripts/dev stop
$ ./scripts/dev start
```

Get containers CPU and memory requests:

```
$ kubectl get pods -A -o custom-columns="NAMESPACE:.metadata.namespace,POD:.metadata.name,CONTAINER:.spec.containers[*].name,CPU_REQUEST:.spec.containers[*].resources.requests.cpu,MEM_REQUEST:.spec.containers[*].resources.requests.memory"
```
