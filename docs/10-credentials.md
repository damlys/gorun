# Credentials

## Docker Hub

Login:

```
$ export DOCKERHUB_USERNAME="..."
$ export DOCKERHUB_TOKEN="..."
$ docker login --username="$DOCKERHUB_USERNAME" --password="$DOCKERHUB_TOKEN"
```

## GitHub

Login...

```
$ gh auth login
```

## Google Cloud Platform

Login...

```
$ gcloud auth login
$ gcloud auth application-default login
$ gcloud config set account "...@gmail.com"
```

...or create [a service account key](https://cloud.google.com/iam/docs/keys-create-delete)
and export it as an environment variable:

```
$ export GOOGLE_CREDENTIALS="..."
$ echo "$GOOGLE_CREDENTIALS" | gcloud auth activate-service-account --key-file="/dev/stdin"
$ export GOOGLE_APPLICATION_CREDENTIALS="/tmp/GOOGLE_APPLICATION_CREDENTIALS.json" && echo "$GOOGLE_CREDENTIALS" >"$GOOGLE_APPLICATION_CREDENTIALS"
```
