# Releases

## Kubernetes raw manifests

tbd

## Helm releases

tbd

## Terraform modules

```
$ ./scripts/terraform-module test "dev-environment"
$ terraform -chdir="terraform/modules/dev-environment" fmt -check

$ terraform -chdir="terraform/modules/dev-environment" init
$ terraform -chdir="terraform/modules/dev-environment" validate
$ terraform -chdir="terraform/modules/dev-environment" plan
$ terraform -chdir="terraform/modules/dev-environment" apply
```
