#!/bin/bash

function set_permissions {
  gcloud --project="gogcp-main-2" iam service-accounts add-iam-policy-binding "gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com" \
    --member="serviceAccount:gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

  gcloud --project="gogcp-main-2" iam service-accounts add-iam-policy-binding "gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com" \
    --member="user:damlys.test@gmail.com" \
    --role="roles/iam.serviceAccountTokenCreator"
}

function stateful_kuard {
  local entrypoint="https://stateful-kuard.gogke-test-2.damlys.pl"
  local identity_token
  local impersonate_token
  local fake_token
  identity_token="$(gcloud auth print-identity-token)"
  impersonate_token="$(gcloud auth print-identity-token --impersonate-service-account="gha-damlys-gorun@gogcp-main-2.iam.gserviceaccount.com" --include-email)"
  fake_token=""

  printf " ---\n\n"

  # 200 Success
  curl "${entrypoint}/healthy"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl "${entrypoint}/ready"
  printf "\n\n --- \n\n"

  # 200 Success
  curl -H "Authorization: Bearer ${identity_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"

  # 200 Success
  curl -H "Authorization: Bearer ${impersonate_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl -H "Authorization: Bearer ${fake_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"
}

stateful_kuard
