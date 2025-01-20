# Releases

## Kubernetes raw manifests

tbd

## Helm releases

tbd

## Terraform modules

```
$ ./scripts/terraform-module test "kuard"
$ terraform -chdir="terraform-modules/kuard" init
$ terraform -chdir="terraform-modules/kuard" validate
$ terraform -chdir="terraform-modules/kuard" plan
$ terraform -chdir="terraform-modules/kuard" apply
```
