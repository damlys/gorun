# Internal Developer Platform (IDP)

## Kubernetes clusters

- [gke_gorun-dev-2_europe-central2-a_dev](https://console.cloud.google.com/kubernetes/clusters/details/europe-central2-a/dev/details?project=gorun-dev-2)

## Docker images registries

- [europe-central2-docker.pkg.dev/gorun-general-2/private-docker-images](https://console.cloud.google.com/artifacts/docker/gorun-general-2/europe-central2/private-docker-images?project=gorun-general-2)
- [europe-central2-docker.pkg.dev/gorun-general-2/public-docker-images](https://console.cloud.google.com/artifacts/docker/gorun-general-2/europe-central2/public-docker-images?project=gorun-general-2)

```
$ gcloud auth configure-docker "europe-central2-docker.pkg.dev"
```

## Helm charts registries

- [oci://europe-central2-docker.pkg.dev/gorun-general-2/private-helm-charts](https://console.cloud.google.com/artifacts/docker/gorun-general-2/europe-central2/private-helm-charts?project=gorun-general-2)
- [oci://europe-central2-docker.pkg.dev/gorun-general-2/public-helm-charts](https://console.cloud.google.com/artifacts/docker/gorun-general-2/europe-central2/public-helm-charts?project=gorun-general-2)

```
$ gcloud auth application-default print-access-token | helm registry login --username="oauth2accesstoken" --password-stdin "europe-central2-docker.pkg.dev"
```

## Terraform submodules registries

- [gorun-general-2-private-terraform-modules](https://console.cloud.google.com/storage/browser/gorun-general-2-private-terraform-modules?project=gorun-general-2)
- [gorun-general-2-public-terraform-modules](https://console.cloud.google.com/storage/browser/gorun-general-2-public-terraform-modules?project=gorun-general-2)

## GitHub repositories

- [damlys/gorun](https://github.com/damlys/gorun)
- [damlys/gomod](https://github.com/damlys/gomod)

```
$ gh auth login
$ export GITHUB_TOKEN="$(gh auth token)"
$ gh auth status
```

### GitHub Actions workflows

Workload identity provider: [projects/715614799977/locations/global/workloadIdentityPools/github/providers/github-actions](https://console.cloud.google.com/iam-admin/workload-identity-pools/pool/github?project=gorun-general-2)

Service accounts:

- [gha-damlys-gorun@gorun-general-2.iam.gserviceaccount.com](https://console.cloud.google.com/iam-admin/serviceaccounts/details/117605750665855275146?project=gorun-general-2)
- [gha-damlys-gomod@gorun-general-2.iam.gserviceaccount.com](https://console.cloud.google.com/iam-admin/serviceaccounts/details/102529506182381509181?project=gorun-general-2)

## SOPS encryption keys

- [projects/gorun-general-2/locations/europe-central2/keyRings/sops/cryptoKeys/gh-damlys-gorun](https://console.cloud.google.com/security/kms/key/manage/europe-central2/sops/gh-damlys-gorun?project=gorun-general-2)
- [projects/gorun-general-2/locations/europe-central2/keyRings/sops/cryptoKeys/gh-damlys-gomod](https://console.cloud.google.com/security/kms/key/manage/europe-central2/sops/gh-damlys-gomod?project=gorun-general-2)

## Terraform state buckets

- [gorun-general-2-tfstate](https://console.cloud.google.com/storage/browser/gorun-general-2-tfstate?project=gorun-general-2)

## Google Cloud Platform projects

- [gorun-general](https://console.cloud.google.com/home/dashboard?project=gorun-general-2)
- [gorun-dev](https://console.cloud.google.com/home/dashboard?project=gorun-dev-2)
- [gorun-prod](https://console.cloud.google.com/home/dashboard?project=gorun-prod-2)

```
$ gcloud auth login
$ gcloud auth application-default login
$ gcloud config set account "damian.lysiak@gmail.com"
$ gcloud config set project "gorun-general-2"
$ gcloud info
```
