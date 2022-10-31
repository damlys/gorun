# Go deployment platform

Google Cloud config

```shell
$ gcloud auth login
$ gcloud auth application-default login
$ gcloud config set account "damian.lysiak@gmail.com"
$ gcloud config set project "$(terraform output -raw project_id)"
```

Terraform Cloud config

```shell
$ terraform login
```

Initialize module

```shell
$ terraform init
```

Validate module

```shell
$ terraform validate
$ terraform plan
```

Deploy

```shell
$ terraform apply
```

Destroy

```shell
$ terraform destroy
$ terraform state rm $(terraform state list)
```
