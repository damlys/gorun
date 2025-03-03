# Releases

## Kubernetes raw manifests

tbd

## Helm releases

tbd

## Terraform modules

```
$ ./scripts/terraform-module test "projects/kuard/terraform-modules/kuard"
$ terraform -chdir="projects/kuard/terraform-modules/kuard" init
$ terraform -chdir="projects/kuard/terraform-modules/kuard" validate
$ terraform -chdir="projects/kuard/terraform-modules/kuard" plan
$ terraform -chdir="projects/kuard/terraform-modules/kuard" apply
```
