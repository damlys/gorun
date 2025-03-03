# Artifacts

## Docker images

```
$ ./scripts/docker-image build "projects/kuard/docker-images/kuard"
$ ./scripts/docker-image test "projects/kuard/docker-images/kuard"
$ ./scripts/docker-image pre-publish "projects/kuard/docker-images/kuard"
$ ./scripts/docker-image publish "projects/kuard/docker-images/kuard"
$ ./scripts/docker-image show "projects/kuard/docker-images/kuard"
```

## Helm charts

```
$ ./scripts/helm-chart build "projects/kuard/helm-charts/kuard"
$ ./scripts/helm-chart test "projects/kuard/helm-charts/kuard"
$ ./scripts/helm-chart pre-publish "projects/kuard/helm-charts/kuard"
$ ./scripts/helm-chart publish "projects/kuard/helm-charts/kuard"
$ ./scripts/helm-chart show "projects/kuard/helm-charts/kuard"
```

## Terraform submodules

```
$ ./scripts/terraform-submodule build "projects/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule test "projects/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule pre-publish "projects/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule publish "projects/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule show "projects/kuard/terraform-submodules/kuard"
```
