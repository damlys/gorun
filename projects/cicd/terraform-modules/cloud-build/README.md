This module manages Google Cloud Build.

```
$ terraform apply -target=google_secret_manager_secret.github_token
$ terraform apply
```

Links:

- https://docs.cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=2nd-gen
  - https://github.com/apps/google-cloud-build
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_repository
- https://docs.cloud.google.com/build/docs/automating-builds/github/build-repos-from-github?generation=2nd-gen
  - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuild_trigger
- https://docs.cloud.google.com/build/docs/build-config-file-schema
