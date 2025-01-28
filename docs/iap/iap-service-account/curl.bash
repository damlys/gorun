#!/bin/bash
set -ex

# backend service: gkegw1-rxra-kuar-demo-kuard-http-server-80-v49bg5xn0q9o
# aud: /projects/764086219165/global/backendServices/5244371705378939478
# client id: 764086219165-odk048stmh8m26dvs581a969ko87c6gh.apps.googleusercontent.com

function main {
  local client_id="764086219165-odk048stmh8m26dvs581a969ko87c6gh.apps.googleusercontent.com" # https://console.cloud.google.com/auth/clients/764086219165-odk048stmh8m26dvs581a969ko87c6gh.apps.googleusercontent.com?project=gogke-test-0
  local service_account="iap-accessor@gogke-test-0.iam.gserviceaccount.com"                  # https://console.cloud.google.com/iam-admin/serviceaccounts/details/106872722214711289330?project=gogke-test-0
  local request_url="https://kuard.gogke-test-7.damlys.pl/healthy"
  local id_token

  id_token=$(
    gcloud auth print-identity-token \
      --audiences "$client_id" \
      --impersonate-service-account "$service_account" \
      --include-email
  )

  curl -H "Authorization: Bearer $id_token" "$request_url"
}

main "$@"
