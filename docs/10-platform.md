# Internal Developer Platform (IDP)

## Google Cloud Platform projects

- [gogcp-main-2](https://console.cloud.google.com/home/dashboard?project=gogcp-main-2)
- [gogcp-test-2](https://console.cloud.google.com/home/dashboard?project=gogcp-test-2)
- [gogcp-prod-2](https://console.cloud.google.com/home/dashboard?project=gogcp-prod-2)

```
$ gcloud config set project "gogcp-main-2"
$ gcloud config set compute/region "europe-central2"
$ gcloud config set compute/zone "europe-central2-a"
```

## Terraform state buckets

- [gogcp-main-2-terraform-state](https://console.cloud.google.com/storage/browser/gogcp-main-2-terraform-state?project=gogcp-main-2)

## Docker images registries

- [europe-central2-docker.pkg.dev/gogcp-main-2/public-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-2/europe-central2/public-docker-images?project=gogcp-main-2)
- [europe-central2-docker.pkg.dev/gogcp-main-2/private-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-2/europe-central2/private-docker-images?project=gogcp-main-2)

```
$ gcloud auth configure-docker "europe-central2-docker.pkg.dev"
```

## Helm charts registries

- [oci://europe-central2-docker.pkg.dev/gogcp-main-2/public-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-2/europe-central2/public-helm-charts?project=gogcp-main-2)
- [oci://europe-central2-docker.pkg.dev/gogcp-main-2/private-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-2/europe-central2/private-helm-charts?project=gogcp-main-2)
- [oci://europe-central2-docker.pkg.dev/gogcp-main-2/external-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-2/europe-central2/external-helm-charts?project=gogcp-main-2)

```
$ gcloud auth print-access-token | helm registry login --username="oauth2accesstoken" --password-stdin "europe-central2-docker.pkg.dev"
```

## Terraform submodules registries

- [gogcp-main-2-public-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-2-public-terraform-modules?project=gogcp-main-2)
- [gogcp-main-2-private-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-2-private-terraform-modules?project=gogcp-main-2)

## Kubernetes clusters

- [gke_gogcp-test-2_europe-central2-a_gogke-test-2](https://console.cloud.google.com/kubernetes/clusters/details/europe-central2-a/gogke-test-2/details?project=gogcp-test-2)

```
$ gcloud --project="gogcp-test-2" container clusters --region="europe-central2-a" get-credentials "gogke-test-2"
$ kubectl config set-context "gke_gogcp-test-2_europe-central2-a_gogke-test-2"
$ kubectl config set-context --current --namespace="gomod-test-2"
```
