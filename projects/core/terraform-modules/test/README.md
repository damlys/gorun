```
$ terraform apply -target=module.test_platform.helm_release.kyverno
$ terraform apply -target=module.test_platform.helm_release.velero
$ terraform apply -target=module.test_platform.helm_release.cert_manager
$ terraform apply
```
