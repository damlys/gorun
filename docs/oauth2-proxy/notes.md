console.cloud.google.com/apis/credentials

console.cloud.google.com/auth/overview

https://console.cloud.google.com/auth/clients/583672822209-2rd2f2bf5780m8faej9us2nhl4mgme7q.apps.googleusercontent.com?project=gogcp-test-2

```
$ terraform -chdir="projects/o11y/terraform-modules/test" apply -target=helm_release.stateless_kuard_oauth2_proxy -auto-approve
$ terraform -chdir="projects/o11y/terraform-modules/test" apply -target=helm_release.istio_discovery -auto-approve
$ terraform -chdir="projects/demo/terraform-modules/kuard" apply -target=module.this -auto-approve
$ ./docs/oauth2-proxy/test.bash
```
