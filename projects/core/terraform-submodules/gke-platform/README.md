https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-loadbalancer

```
$ kubectl --namespace=istio-ingress patch service istio-ingress-istio --patch='{"spec":{"externalTrafficPolicy":"Local"}}'
```
