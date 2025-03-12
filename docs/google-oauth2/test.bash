#!/bin/bash

function stateful_kuard {
  local entrypoint="https://stateful-kuard.gogke-test-2.damlys.pl"
  local identity_token
  local fake_token
  identity_token="$(gcloud auth print-identity-token)"
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

  # 401 Unauthorized
  curl -H "Authorization: Bearer ${fake_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"
}

stateful_kuard
