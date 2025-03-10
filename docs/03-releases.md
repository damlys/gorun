# Releases

## Kubernetes raw manifests

tbd

## Helm releases

tbd

## Terraform modules

```
$ ./scripts/terraform-module test "projects/demo/terraform-modules/kuard"
$ terraform -chdir="projects/demo/terraform-modules/kuard" init
$ terraform -chdir="projects/demo/terraform-modules/kuard" validate
$ terraform -chdir="projects/demo/terraform-modules/kuard" plan
$ terraform -chdir="projects/demo/terraform-modules/kuard" apply
```
