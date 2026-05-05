# Internal Developer Platform (IDP)

## Google Cloud Platform projects

- [gogcp-main-8](https://console.cloud.google.com/home/dashboard?project=gogcp-main-8)
- [gogcp-test-8](https://console.cloud.google.com/home/dashboard?project=gogcp-test-8)
- [gogcp-prod-8](https://console.cloud.google.com/home/dashboard?project=gogcp-prod-8)

```
$ gcloud config set project "gogcp-main-8"
$ gcloud config set compute/region "europe-central2"
$ gcloud config set compute/zone "europe-central2-a"
```

## Terraform state buckets

- [gogcp-main-8-terraform-state](https://console.cloud.google.com/storage/browser/gogcp-main-8-terraform-state?project=gogcp-main-8)

## Docker images registries

- [europe-central2-docker.pkg.dev/gogcp-main-8/public-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-8/europe-central2/public-docker-images?project=gogcp-main-8)
- [europe-central2-docker.pkg.dev/gogcp-main-8/private-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-8/europe-central2/private-docker-images?project=gogcp-main-8)

```
$ gcloud auth configure-docker "europe-central2-docker.pkg.dev"
```

## Helm charts registries

- [oci://europe-central2-docker.pkg.dev/gogcp-main-8/public-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-8/europe-central2/public-helm-charts?project=gogcp-main-8)
- [oci://europe-central2-docker.pkg.dev/gogcp-main-8/private-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-8/europe-central2/private-helm-charts?project=gogcp-main-8)

```
$ gcloud auth print-access-token | helm registry login --username="oauth2accesstoken" --password-stdin "europe-central2-docker.pkg.dev"
```

## Terraform submodules registries

- [gogcp-main-8-public-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-8-public-terraform-modules?project=gogcp-main-8)
- [gogcp-main-8-private-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-8-private-terraform-modules?project=gogcp-main-8)

## Kubernetes clusters

- [gke_gogcp-test-8_europe-central2-a_gogke-test-8](https://console.cloud.google.com/kubernetes/clusters/details/europe-central2-a/gogke-test-8/details?project=gogcp-test-8)

```
$ gcloud --project="gogcp-test-8" container clusters --region="europe-central2-a" get-credentials "gogke-test-8"
$ kubectl config set-context "gke_gogcp-test-8_europe-central2-a_gogke-test-8"
$ kubectl config set-context --current --namespace="gomod-test-8"
```
