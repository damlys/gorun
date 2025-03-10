# Artifacts

## Docker images

```
$ ./scripts/docker-image build "projects/demo/docker-images/kuard"
$ ./scripts/docker-image test "projects/demo/docker-images/kuard"
$ ./scripts/docker-image pre-publish "projects/demo/docker-images/kuard"
$ ./scripts/docker-image publish "projects/demo/docker-images/kuard"
$ ./scripts/docker-image show "projects/demo/docker-images/kuard"
```

## Helm charts

```
$ ./scripts/helm-chart build "projects/demo/helm-charts/kuard"
$ ./scripts/helm-chart test "projects/demo/helm-charts/kuard"
$ ./scripts/helm-chart pre-publish "projects/demo/helm-charts/kuard"
$ ./scripts/helm-chart publish "projects/demo/helm-charts/kuard"
$ ./scripts/helm-chart show "projects/demo/helm-charts/kuard"
```

## Terraform submodules

```
$ ./scripts/terraform-submodule build "projects/demo/terraform-submodules/kuard"
$ ./scripts/terraform-submodule test "projects/demo/terraform-submodules/kuard"
$ ./scripts/terraform-submodule pre-publish "projects/demo/terraform-submodules/kuard"
$ ./scripts/terraform-submodule publish "projects/demo/terraform-submodules/kuard"
$ ./scripts/terraform-submodule show "projects/demo/terraform-submodules/kuard"
```
