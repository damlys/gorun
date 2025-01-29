# data "http" "debug_request" {
#   url = "https://grafana.gogke-test-7.damlys.pl/healthz"
#
#   request_headers = {
#     "Authorization" = "Bearer ${data.google_service_account_id_token.grafana.id_token}"
#   }
# }
#
# output "debug_response" {
#   value = data.http.debug_request.response_body
# }
