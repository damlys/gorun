# Releases

## Kubernetes raw manifests

tbd

## Helm releases

tbd

## Terraform modules

```
$ ./scripts/terraform-module test "kuard" "kuard"
$ terraform -chdir="scopes/kuard/terraform-modules/kuard" init
$ terraform -chdir="scopes/kuard/terraform-modules/kuard" validate
$ terraform -chdir="scopes/kuard/terraform-modules/kuard" plan
$ terraform -chdir="scopes/kuard/terraform-modules/kuard" apply
```
