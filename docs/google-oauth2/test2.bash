#!/bin/bash

function stateless_kuard {
  local entrypoint="https://stateless-kuard.gogke-test-2.damlys.pl"
  local identity_token
  local custom_token
  identity_token="$(gcloud auth print-identity-token)"
  custom_token=""

  printf " ---\n\n"

  # 200 Success
  curl "${entrypoint}/healthy"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl "${entrypoint}/ready"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl -H "Authorization: Bearer ${identity_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"

  # 200 Success
  curl -H "Authorization: Bearer ${custom_token}" "${entrypoint}/ready"
  printf "\n\n --- \n\n"
}

stateless_kuard
