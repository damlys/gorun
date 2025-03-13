#!/bin/bash

function stateless_kuard {
  local entrypoint="https://stateless-kuard.gogke-test-2.damlys.pl"
  local access_token
  local identity_token
  local custom_token
  access_token="$(gcloud auth print-access-token)"
  identity_token="$(gcloud auth print-identity-token)"
  custom_token="XXX"

  printf " ---\n\n"

  # 200 Success
  curl -o /dev/null -s -w '%{http_code}\n' "${entrypoint}/healthy"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl -o /dev/null -s -w '%{http_code}\n' "${entrypoint}"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl -o /dev/null -s -w '%{http_code}\n' -H "Authorization: Bearer ${access_token}" "${entrypoint}"
  printf "\n\n --- \n\n"

  # 401 Unauthorized
  curl -o /dev/null -s -w '%{http_code}\n' -H "Authorization: Bearer ${identity_token}" "${entrypoint}"
  printf "\n\n --- \n\n"

  # 200 Success
  curl -o /dev/null -s -w '%{http_code}\n' -H "Authorization: Bearer ${custom_token}" "${entrypoint}"
  printf "\n\n --- \n\n"
}

stateless_kuard
