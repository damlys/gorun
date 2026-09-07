# Internal Developer Platform (IDP)

## Google Cloud Platform projects

- [gogcp-main-9](https://console.cloud.google.com/home/dashboard?project=gogcp-main-9)
- [gogcp-test-9](https://console.cloud.google.com/home/dashboard?project=gogcp-test-9)
- [gogcp-prod-9](https://console.cloud.google.com/home/dashboard?project=gogcp-prod-9)

```
$ gcloud config set project "gogcp-main-9"
$ gcloud config set compute/region "europe-central2"
$ gcloud config set compute/zone "europe-central2-a"
```

## Terraform state buckets

- [gogcp-main-9-terraform-state](https://console.cloud.google.com/storage/browser/gogcp-main-9-terraform-state?project=gogcp-main-9)

## Docker images registries

- [europe-central2-docker.pkg.dev/gogcp-main-9/public-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-9/europe-central2/public-docker-images?project=gogcp-main-9)
- [europe-central2-docker.pkg.dev/gogcp-main-9/private-docker-images](https://console.cloud.google.com/artifacts/docker/gogcp-main-9/europe-central2/private-docker-images?project=gogcp-main-9)

```
$ gcloud auth configure-docker "europe-central2-docker.pkg.dev"
```

## Helm charts registries

- [oci://europe-central2-docker.pkg.dev/gogcp-main-9/public-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-9/europe-central2/public-helm-charts?project=gogcp-main-9)
- [oci://europe-central2-docker.pkg.dev/gogcp-main-9/private-helm-charts](https://console.cloud.google.com/artifacts/docker/gogcp-main-9/europe-central2/private-helm-charts?project=gogcp-main-9)

```
$ gcloud auth print-access-token | helm registry login --username="oauth2accesstoken" --password-stdin "europe-central2-docker.pkg.dev"
```

## Terraform submodules registries

- [gogcp-main-9-public-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-9-public-terraform-modules?project=gogcp-main-9)
- [gogcp-main-9-private-terraform-modules](https://console.cloud.google.com/storage/browser/gogcp-main-9-private-terraform-modules?project=gogcp-main-9)

## Kubernetes clusters

- [gke_gogcp-test-9_europe-central2-a_gogke-test-9](https://console.cloud.google.com/kubernetes/clusters/details/europe-central2-a/gogke-test-9/details?project=gogcp-test-9)

```
$ gcloud --project="gogcp-test-9" container clusters --region="europe-central2-a" get-credentials "gogke-test-9"
$ kubectl config set-context "gke_gogcp-test-9_europe-central2-a_gogke-test-9"
$ kubectl config set-context --current --namespace="gomod-test-9"
```
