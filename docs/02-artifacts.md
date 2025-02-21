# Artifacts

## Docker images

```
$ ./scripts/docker-image build "scopes/kuard/docker-images/kuard"
$ ./scripts/docker-image test "scopes/kuard/docker-images/kuard"
$ ./scripts/docker-image pre-publish "scopes/kuard/docker-images/kuard"
$ ./scripts/docker-image publish "scopes/kuard/docker-images/kuard"
$ ./scripts/docker-image show "scopes/kuard/docker-images/kuard"
```

## Helm charts

```
$ ./scripts/helm-chart build "scopes/kuard/helm-charts/kuard"
$ ./scripts/helm-chart test "scopes/kuard/helm-charts/kuard"
$ ./scripts/helm-chart pre-publish "scopes/kuard/helm-charts/kuard"
$ ./scripts/helm-chart publish "scopes/kuard/helm-charts/kuard"
$ ./scripts/helm-chart show "scopes/kuard/helm-charts/kuard"
```

## Terraform submodules

```
$ ./scripts/terraform-submodule build "scopes/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule test "scopes/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule pre-publish "scopes/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule publish "scopes/kuard/terraform-submodules/kuard"
$ ./scripts/terraform-submodule show "scopes/kuard/terraform-submodules/kuard"
```
