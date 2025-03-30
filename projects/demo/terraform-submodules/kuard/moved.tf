moved {
  from = module.stateless_kuard_gateway_route
  to   = module.stateless_kuard_gateway_http_route
}

moved {
  from = module.stateless_kuard_gateway_redirect
  to   = module.stateless_kuard_gateway_domain_redirect
}

moved {
  from = module.stateful_kuard_gateway_route
  to   = module.stateful_kuard_gateway_http_route
}
